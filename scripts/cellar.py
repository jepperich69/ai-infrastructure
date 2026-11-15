"""cellar.py -- run Python/Gurobi jobs on the cellar compute server from the laptop (see compute_server/README.md).

  python cellar.py status                      up or asleep, load, memory, running jobs
  python cellar.py wake                        Wake-on-LAN, then wait for ssh
  python cellar.py sleep [--force]             suspend the cellar now (refuses while a job runs)
  python cellar.py env                         compare the pyopt env and jr_optlib on laptop and cellar
  python cellar.py run --project DIR [--src code] -- CMD...
                                               snapshot DIR/src by content hash, store it once, start CMD in tmux
  python cellar.py jobs [--project DIR]        list runs
  python cellar.py log RUNID [-n 40]           tail a run's log
  python cellar.py pull RUNID                  copy new/changed files + run.log + manifest.json back into
                                               DIR/src/remote_runs/RUNID/ and update DIR/_remote_runs.csv
  python cellar.py kill RUNID
  python cellar.py install                     (re)install the cellar helper and set the idle-sleep timer
  python cellar.py doctor                      check this laptop's side (config, key, ssh config, Tailscale, relay)

Machine-specific values (MAC, IPs, paths) live in compute_server/local/cellar_config.json (gitignored).

Snapshots: every file in DIR/src (minus __pycache__, remote_runs, .git, *.pyc) is hashed; the job hash is the
SHA-256 of that sorted manifest. ~/store/<hash>/ on the cellar holds each snapshot once; each run works on its own
copy in ~/runs/<runid>/work, so a script that appends to its CSV resumes from the laptop's current state.
Each run records the job hash, the pip-freeze fingerprints of both pyopt envs and the jr_optlib commit of both
sides. The laptop stays the master copy: results come back by `pull`, nothing is synced the other way.
"""
import argparse, csv, hashlib, io, json, os, re, shlex, shutil, socket, subprocess, sys, tarfile, time
from pathlib import Path

HERE = Path(__file__).resolve().parent
CFG_FILE = HERE.parent / "compute_server" / "local" / "cellar_config.json"   # gitignored; template: cellar_config.example.json
if not CFG_FILE.exists():
    sys.exit("missing %s\ncopy compute_server/cellar_config.example.json there and fill it in (INSTALL.md Part G)" % CFG_FILE)
CFG = json.loads(CFG_FILE.read_text())
HELPER = HERE.parent / "compute_server" / "remote" / "cellar_job.py"
SSH = CFG["ssh_exe"]
HOST = CFG["ssh_host"]
EXCLUDE_DIRS = {"__pycache__", "remote_runs", ".git", ".pytest_cache"}
CSV_FIELDS = ["run_id", "submitted", "src", "cmd", "hash", "env_match", "jr_optlib_laptop", "jr_optlib_cellar",
              "state", "wall_s", "cpu_s", "peak_rss_mb", "results"]


# ---------------------------------------------------------------- ssh helpers
def ssh(cmd, inp=None, timeout=120, check=True, connect=10):
    args = [SSH, "-o", "BatchMode=yes", "-o", "ConnectTimeout=%d" % connect, HOST, cmd]
    r = subprocess.run(args, input=inp, capture_output=True, timeout=timeout)
    if check and r.returncode != 0:
        sys.exit("ssh failed (%d): %s\n%s" % (r.returncode, cmd[:200], r.stderr.decode(errors="replace")))
    return r


def up(connect=5):
    try:
        return ssh("true", timeout=connect + 10, check=False, connect=connect).returncode == 0
    except subprocess.TimeoutExpired:
        return False


def magic_packet():
    mac = bytes.fromhex(CFG["mac"].replace(":", "").replace("-", ""))
    pkt = b"\xff" * 6 + mac * 16
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    for _ in range(3):
        for addr in CFG["wol_broadcast"]:
            for port in (9, 7):
                try:
                    s.sendto(pkt, (addr, port))
                except OSError:
                    pass
    s.close()


def relay():
    """Ask the phone relay (OnePlus, Termux sshd, Tailscale) to send the magic packet from inside the home LAN."""
    try:
        r = subprocess.run([SSH, "-o", "BatchMode=yes", "-o", "ConnectTimeout=15", CFG["relay_host"], "wake-cellar"],
                           capture_output=True, text=True, timeout=30)
    except subprocess.TimeoutExpired:
        print("phone relay: timeout", flush=True)
        return False
    msg = (r.stdout or r.stderr).strip()
    print("phone relay:", msg if r.returncode == 0 else "not reachable (%s)" % msg[:120], flush=True)
    return r.returncode == 0


def wake(quiet=False):
    if up():
        return True
    if not quiet:
        print("cellar not answering: sending Wake-on-LAN (local packet + phone relay) ...", flush=True)
    t0 = time.time()
    relay_tries = 0
    while time.time() - t0 < CFG["wake_timeout_s"]:
        magic_packet()                      # only helps on the home LAN
        if relay_tries == 0 or (relay_tries == 1 and time.time() - t0 > 60):
            relay_tries += 1                # phone relay: works from anywhere on Tailscale; once, then once more after 60 s
            relay()
        if up(connect=5):
            print("cellar up after %d s" % (time.time() - t0), flush=True)
            return True
        time.sleep(5)
    sys.exit("cellar did not wake within %d s (BIOS Wake-on-LAN on? laptop on the home LAN?)" % CFG["wake_timeout_s"])


def ensure_helper():
    local = hashlib.sha256(HELPER.read_bytes()).hexdigest()
    r = ssh("sha256sum ~/bin/cellar_job.py 2>/dev/null | cut -c1-64", check=False)
    if r.stdout.decode().strip() != local:
        ssh("mkdir -p ~/bin ~/store ~/runs && cat > ~/bin/cellar_job.py && chmod +x ~/bin/cellar_job.py", inp=HELPER.read_bytes())


# ---------------------------------------------------------------- fingerprints
def freeze_local():
    r = subprocess.run([CFG["laptop_pyopt"], "-m", "pip", "list", "--format=freeze"], capture_output=True, text=True)
    return sorted(l.strip().lower() for l in r.stdout.splitlines() if l.strip())


def freeze_cellar():
    r = ssh("%s -m pip list --format=freeze" % CFG["cellar_pyopt"])
    return sorted(l.strip().lower() for l in r.stdout.decode().splitlines() if l.strip())


def fp(lines):
    return hashlib.sha256("\n".join(lines).encode()).hexdigest()[:12]


def optlib_local():
    g = lambda *a: subprocess.run(["git", "-C", CFG["jr_optlib"], *a], capture_output=True, text=True).stdout.strip()
    sha = g("rev-parse", "--short", "HEAD")
    dirty = bool(g("status", "--porcelain", "--untracked-files=no"))
    pushed = subprocess.run(["git", "-C", CFG["jr_optlib"], "merge-base", "--is-ancestor", "HEAD", "origin/main"]).returncode == 0
    return sha + ("+dirty" if dirty else "") + ("" if pushed else "+unpushed")


def optlib_cellar():
    return ssh("git -C %s rev-parse --short HEAD" % CFG["cellar_jr_optlib"], check=False).stdout.decode().strip() or "none"


def key_versions(lines):
    keep = ("gurobipy", "numpy", "scipy", "pandas", "networkx", "cvxpy", "clarabel", "sympy", "matplotlib", "jr-optlib", "jr_optlib")
    return {l.split("==")[0]: l.split("==")[-1] for l in lines if l.split("==")[0] in keep}


# ---------------------------------------------------------------- snapshot
def manifest(src):
    man = {}
    for root, dirs, files in os.walk(src):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUDE_DIRS)
        for f in sorted(files):
            if f.endswith(".pyc"):
                continue
            p = Path(root) / f
            man[p.relative_to(src).as_posix()] = hashlib.sha256(p.read_bytes()).hexdigest()
    return man


def upload(src, man, h):
    if ssh("test -f ~/store/%s/.complete" % h, check=False).returncode == 0:
        return False
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w") as t:
        for rel in man:
            t.add(str(Path(src) / rel), arcname=rel, recursive=False)
        data = json.dumps(man, indent=0).encode()
        ti = tarfile.TarInfo(".manifest.json"); ti.size = len(data)
        t.addfile(ti, io.BytesIO(data))
    tmp = "~/store/.tmp-%s" % h
    ssh("rm -rf {t} && mkdir -p {t} && tar -xf - -C {t} && touch {t}/.complete && mv -T {t} ~/store/{h}".format(t=tmp, h=h),
        inp=buf.getvalue(), timeout=1800)
    return True


# ---------------------------------------------------------------- local run register
def csv_path(project):
    return Path(project) / "_remote_runs.csv"


def register(project, row):
    p = csv_path(project)
    rows = list(csv.DictReader(open(p, newline=""))) if p.exists() else []
    rows = [r for r in rows if r["run_id"] != row["run_id"]]
    rows.append(row)
    rows.sort(key=lambda r: r["run_id"])
    with open(p, "w", newline="") as f:
        w = csv.DictWriter(f, CSV_FIELDS, extrasaction="ignore")
        w.writeheader()
        w.writerows(rows)


def find_row(run_id):
    """The project of a run is in the cellar's job.json."""
    r = ssh("cat ~/runs/%s/job.json" % shlex.quote(run_id), check=False)
    if r.returncode != 0:
        sys.exit("no run %s on the cellar" % run_id)
    return json.loads(r.stdout)


# ---------------------------------------------------------------- commands
def cmd_status(a):
    if not up():
        print("cellar: DOWN or asleep (python cellar.py wake)")
        return
    r = ssh("uptime; free -m | awk 'NR==2{print \"mem MB: total \"$2\", available \"$7}'; nproc | sed 's/^/threads: /'; "
            "tmux ls 2>/dev/null | grep -c '^job-' | sed 's/^/tmux jobs: /'")
    print("cellar: UP\n" + r.stdout.decode().strip())
    ensure_helper()
    for l in ssh("python3 ~/bin/cellar_job.py list").stdout.decode().splitlines()[-10:]:
        j = json.loads(l)
        if j["state"] in ("running", "lost") or a.all:
            print("  %-26s %-8s %s" % (j["id"], j["state"], j["cmd"][:70]))


def cmd_env(a):
    wake()
    L, C = freeze_local(), freeze_cellar()
    kl, kc = key_versions(L), key_versions(C)
    print("pyopt fingerprint  laptop %s   cellar %s   %s" % (fp(L), fp(C), "MATCH" if L == C else "DIFFER"))
    for k in sorted(set(kl) | set(kc)):
        flag = "" if kl.get(k) == kc.get(k) else "   <-- differs"
        print("  %-12s laptop %-12s cellar %-12s%s" % (k, kl.get(k, "-"), kc.get(k, "-"), flag))
    ol, oc = optlib_local(), optlib_cellar()
    print("jr_optlib          laptop %s   cellar %s   %s" % (ol, oc, "MATCH" if ol == oc else "DIFFER"))
    only_l = sorted(set(L) - set(C)); only_c = sorted(set(C) - set(L))
    if a.verbose:
        print("only laptop:", ", ".join(only_l)); print("only cellar:", ", ".join(only_c))
    else:
        print("other differing packages: %d laptop-only, %d cellar-only (env -v lists them)" % (len(only_l), len(only_c)))


def cmd_run(a):
    project = Path(a.project).resolve()
    src = project / a.src
    if not src.is_dir():
        sys.exit("no folder %s" % src)
    cmd = " ".join(a.cmd).strip()
    if not cmd:
        sys.exit("give the command after --")
    wake()
    ensure_helper()
    man = manifest(src)
    h = hashlib.sha256(json.dumps(sorted(man.items())).encode()).hexdigest()
    new = upload(src, man, h)
    L, C = freeze_local(), freeze_cellar()
    ol, oc = optlib_local(), optlib_cellar()
    run_id = time.strftime("%Y%m%d-%H%M%S") + "-" + h[:8]
    job = dict(run_id=run_id, project=str(project), project_name=project.name, src=a.src, cmd=cmd, hash=h,
               files=len(man), submitted=time.strftime("%Y-%m-%dT%H:%M:%S"),
               env_laptop=fp(L), env_cellar=fp(C), env_key_laptop=key_versions(L), env_key_cellar=key_versions(C),
               jr_optlib_laptop=ol, jr_optlib_cellar=oc)
    rd = "~/runs/%s" % run_id
    ssh("mkdir -p {r}/work && cp -a ~/store/{h}/. {r}/work/ && rm -f {r}/work/.manifest.json {r}/work/.complete "
        "&& cat > {r}/job.json".format(r=rd, h=h), inp=json.dumps(job, indent=1).encode())
    ssh("tmux new-session -d -s job-{i} 'python3 ~/bin/cellar_job.py run {r}'".format(i=run_id, r=rd))
    register(project, dict(run_id=run_id, submitted=job["submitted"], src=a.src, cmd=cmd, hash=h,
                           env_match=L == C, jr_optlib_laptop=ol, jr_optlib_cellar=oc, state="running"))
    print("started %s  (%s snapshot %s, %d files)" % (run_id, "new" if new else "stored", h[:12], len(man)))
    if L != C:
        print("note: pyopt envs differ (python cellar.py env)")
    if ol != oc:
        print("note: jr_optlib differs: laptop %s, cellar %s" % (ol, oc))


def cmd_jobs(a):
    wake()
    ensure_helper()
    for l in ssh("python3 ~/bin/cellar_job.py list").stdout.decode().splitlines():
        j = json.loads(l)
        if a.project and Path(j.get("project", "")).name != Path(a.project).resolve().name:
            continue
        print("%-26s %-8s %8s s %8s MB  %s" % (j["id"], j["state"], j.get("wall_s", ""), j.get("peak_rss_mb", ""), j["cmd"][:60]))


def cmd_log(a):
    wake()
    print(ssh("tail -n %d ~/runs/%s/run.log" % (a.n, shlex.quote(a.run_id)), check=False).stdout.decode(errors="replace"))


def cmd_pull(a):
    wake()
    job = find_row(a.run_id)
    st = json.loads(ssh("cat ~/runs/%s/status.json 2>/dev/null || echo '{}'" % a.run_id).stdout or b"{}")
    outs = json.loads(ssh("python3 ~/bin/cellar_job.py outputs ~/runs/%s" % a.run_id).stdout)
    dest = Path(job["project"]) / job["src"] / "remote_runs" / a.run_id
    dest.mkdir(parents=True, exist_ok=True)
    if outs:
        names = " ".join(shlex.quote(o["path"]) for o in outs)
        r = ssh("tar -cf - -C ~/runs/%s/work %s" % (a.run_id, names), timeout=3600)
        with tarfile.open(fileobj=io.BytesIO(r.stdout)) as t:
            t.extractall(dest, filter="data")
        for o in outs:
            got = hashlib.sha256((dest / o["path"]).read_bytes()).hexdigest()
            if got != o["sha256"]:
                sys.exit("checksum mismatch on %s" % o["path"])
    (dest / "run.log").write_bytes(ssh("cat ~/runs/%s/run.log" % a.run_id, check=False).stdout)
    (dest / "manifest.json").write_text(json.dumps(dict(job=job, status=st, outputs=outs), indent=1))
    register(job["project"], dict(run_id=a.run_id, submitted=job["submitted"], src=job["src"], cmd=job["cmd"], hash=job["hash"],
                                  env_match=job["env_laptop"] == job["env_cellar"], jr_optlib_laptop=job["jr_optlib_laptop"],
                                  jr_optlib_cellar=job["jr_optlib_cellar"], state=st.get("state", "?"), wall_s=st.get("wall_s", ""),
                                  cpu_s=st.get("cpu_s", ""), peak_rss_mb=st.get("peak_rss_mb", ""),
                                  results=str(dest.relative_to(job["project"])).replace("\\", "/")))
    print("%s: state %s, %d output files -> %s" % (a.run_id, st.get("state"), len(outs), dest))
    for o in outs:
        print("  %s%s (%d bytes)" % (o["path"], " [new]" if o["new"] else " [changed]", o["bytes"]))


def cmd_kill(a):
    wake()
    print(ssh("python3 ~/bin/cellar_job.py kill %s" % shlex.quote(a.run_id)).stdout.decode().strip())


PS = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"


def cmd_sleep(a):
    if not up():
        print("cellar already down or asleep")
        return
    ensure_helper()
    if ssh("python3 ~/bin/cellar_job.py busy", check=False).returncode == 0 and not a.force:
        sys.exit("a job is running; not suspending (use --force)")
    code = "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Application]::SetSuspendState('Suspend', $false, $false)"
    try:
        ssh("nohup %s -NoProfile -Command \"%s\" >/dev/null 2>&1 &" % (PS, code), timeout=20, check=False)
    except subprocess.TimeoutExpired:
        pass
    print("suspend sent")


def cmd_install(a):
    wake()
    ensure_helper()
    m = CFG["idle_sleep_min"]
    r = ssh("%s -NoProfile -Command \"powercfg /change standby-timeout-ac %d; powercfg /q SCHEME_CURRENT SUB_SLEEP STANDBYIDLE "
            "| Select-String 'Current AC'\"" % (PS, m), check=False)
    print("helper installed; Windows idle sleep after %d min ->" % m, r.stdout.decode(errors="replace").strip(), r.stderr.decode(errors="replace").strip())


def cmd_doctor(a):
    """Check this laptop's side of the setup without waking anything. Each FAIL names its fix (INSTALL.md Part G)."""
    bad = 0

    def check(ok, what, fix=""):
        nonlocal bad
        bad += not ok
        print(("OK    " if ok else "FAIL  ") + what + ("" if ok or not fix else "\n      fix: " + fix), flush=True)

    holes = [k for k, v in CFG.items() if "<" in json.dumps(v)]
    check(not holes, "local config filled in (%s)" % CFG_FILE.name, "fill in: " + ", ".join(holes))
    check(Path(SSH).exists(), "ssh client " + SSH, "install Windows OpenSSH client or set ssh_exe")
    key = Path(os.path.expanduser(CFG.get("ssh_key", "~/.ssh/id_ed25519_cellar")))
    check(key.exists() and key.with_suffix(".pub").exists(), "ssh key " + str(key),
          "copy the old laptop's key, or ssh-keygen -t ed25519 -N '' -f %s and authorize the .pub on cellar AND phone" % key)
    sshcfg = Path(os.path.expanduser("~/.ssh/config"))
    txt = sshcfg.read_text(errors="replace") if sshcfg.exists() else ""
    for h in (HOST, CFG["relay_host"]):
        check(re.search(r"(?mi)^\s*Host\s+%s\s*$" % re.escape(h), txt) is not None, "~/.ssh/config has Host " + h,
              "add the Host %s block from INSTALL.md Part G" % h)
    ts = shutil.which("tailscale") or r"C:\Program Files\Tailscale\tailscale.exe"
    try:
        r = subprocess.run([ts, "status", "--peers=false"], capture_output=True, text=True, timeout=15)
        check(r.returncode == 0, "Tailscale running on this laptop", "install Tailscale, log in to the same tailnet")
    except (OSError, subprocess.TimeoutExpired):
        check(False, "Tailscale running on this laptop", "install Tailscale, log in to the same tailnet")
    try:
        r = subprocess.run([SSH, "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", CFG["relay_host"], "true"],
                           capture_output=True, text=True, timeout=25)
        check(r.returncode == 0, "phone relay answers (ssh %s)" % CFG["relay_host"],
              "phone on? Termux sshd + Tailscale up? key authorized? (%s)" % (r.stderr.strip()[:100]))
    except subprocess.TimeoutExpired:
        check(False, "phone relay answers", "phone on, Termux running, Tailscale connected?")
    awake = up()
    print(("OK    " if awake else "INFO  ") + "cellar " + ("answers on ssh" if awake else "not answering (asleep? `cellar.py wake`)"))
    print("%d problem(s)" % bad)
    sys.exit(1 if bad else 0)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sp = ap.add_subparsers(dest="c", required=True)
    s = sp.add_parser("status"); s.add_argument("--all", action="store_true"); s.set_defaults(f=cmd_status)
    sp.add_parser("wake").set_defaults(f=lambda a: wake())
    s = sp.add_parser("sleep"); s.add_argument("--force", action="store_true"); s.set_defaults(f=cmd_sleep)
    s = sp.add_parser("env"); s.add_argument("-v", "--verbose", action="store_true"); s.set_defaults(f=cmd_env)
    s = sp.add_parser("run"); s.add_argument("--project", required=True); s.add_argument("--src", default="code")
    s.add_argument("cmd", nargs=argparse.REMAINDER); s.set_defaults(f=cmd_run)
    s = sp.add_parser("jobs"); s.add_argument("--project"); s.set_defaults(f=cmd_jobs)
    s = sp.add_parser("log"); s.add_argument("run_id"); s.add_argument("-n", type=int, default=40); s.set_defaults(f=cmd_log)
    s = sp.add_parser("pull"); s.add_argument("run_id"); s.set_defaults(f=cmd_pull)
    s = sp.add_parser("kill"); s.add_argument("run_id"); s.set_defaults(f=cmd_kill)
    sp.add_parser("install").set_defaults(f=cmd_install)
    sp.add_parser("doctor").set_defaults(f=cmd_doctor)
    a = ap.parse_args()
    if getattr(a, "cmd", None) and a.cmd[:1] == ["--"]:
        a.cmd = a.cmd[1:]
    a.f(a)


if __name__ == "__main__":
    main()
