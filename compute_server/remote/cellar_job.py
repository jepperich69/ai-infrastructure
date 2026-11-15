#!/usr/bin/env python3
"""Cellar-side job helper (stdlib only). Installed by the laptop's scripts/cellar.py as ~/bin/cellar_job.py.

  cellar_job.py run  <rundir>     run the job described in <rundir>/job.json (called inside tmux)
  cellar_job.py list              one JSON line per run: id, state, project, cmd, times, peak memory
  cellar_job.py outputs <rundir>  files in <rundir>/work that are new or changed against the stored snapshot
  cellar_job.py kill <runid>      stop a running job (tmux session job-<runid>)
  cellar_job.py busy              exit 0 if any job is running, 1 if none

While a job runs, a hidden Windows PowerShell holds a keep-awake request (SetThreadExecutionState), so the
idle-sleep timer cannot suspend the PC mid-job. It releases when the RUNNING flag file disappears.
"""
import hashlib, json, os, resource, signal, subprocess, sys, time
from pathlib import Path

HOME = Path.home()
RUNS = HOME / "runs"
STORE = HOME / "store"
PYOPT_BIN = HOME / "miniforge3" / "envs" / "pyopt" / "bin"
PS = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"


def now():
    return time.strftime("%Y-%m-%dT%H:%M:%S")


def sha(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(1 << 20), b""):
            h.update(b)
    return h.hexdigest()


def write_status(rundir, **kw):
    p = rundir / "status.json"
    st = json.loads(p.read_text()) if p.exists() else {}
    st.update(kw)
    tmp = p.with_suffix(".tmp")
    tmp.write_text(json.dumps(st, indent=1))
    tmp.replace(p)


def keep_awake(flag):
    """Start a hidden Windows process that blocks idle sleep while `flag` exists. Best effort."""
    if not os.path.exists(PS):
        return None
    try:
        win = subprocess.run(["wslpath", "-w", str(flag)], capture_output=True, text=True).stdout.strip()
        code = ("Add-Type -Namespace W -Name P -MemberDefinition '[DllImport(\"kernel32.dll\")] public static extern uint "
                "SetThreadExecutionState(uint f);'; [W.P]::SetThreadExecutionState(0x80000001) | Out-Null; "
                "while (Test-Path -LiteralPath '%s') { Start-Sleep -Seconds 30 }" % win.replace("'", "''"))
        return subprocess.Popen([PS, "-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", code],
                                stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        return None


def run(rundir):
    rundir = Path(rundir)
    job = json.loads((rundir / "job.json").read_text())
    work = rundir / "work"
    flag = rundir / "RUNNING"
    flag.write_text(now())
    ka = keep_awake(flag)
    env = dict(os.environ)
    env["PATH"] = "%s:%s" % (PYOPT_BIN, env.get("PATH", ""))
    env["GRB_LICENSE_FILE"] = str(HOME / "gurobi.lic")
    env.setdefault("OPENBLAS_NUM_THREADS", "1")
    env.setdefault("MKL_NUM_THREADS", "1")
    env["PYTHONUNBUFFERED"] = "1"
    write_status(rundir, state="running", start=now(), host=os.uname().nodename, keep_awake=ka is not None)
    t0 = time.time()
    with open(rundir / "run.log", "ab") as log:
        p = subprocess.Popen(job["cmd"], shell=True, cwd=work, env=env, stdout=log, stderr=subprocess.STDOUT,
                             start_new_session=True)
        write_status(rundir, pid=p.pid)
        rc = p.wait()
    ru = resource.getrusage(resource.RUSAGE_CHILDREN)
    write_status(rundir, state="done" if rc == 0 else "failed", end=now(), exit_code=rc,
                 wall_s=round(time.time() - t0, 1), cpu_s=round(ru.ru_utime + ru.ru_stime, 1),
                 peak_rss_mb=round(ru.ru_maxrss / 1024.0, 1))
    flag.unlink(missing_ok=True)
    if ka is not None:
        try:
            ka.wait(timeout=60)
        except Exception:
            ka.kill()


def runs():
    for d in sorted(RUNS.glob("*/")):
        try:
            job = json.loads((d / "job.json").read_text())
        except Exception:
            continue
        st = json.loads((d / "status.json").read_text()) if (d / "status.json").exists() else {"state": "queued"}
        if st.get("state") == "running" and not (d / "RUNNING").exists():
            st["state"] = "lost"          # wrapper died without writing an end state
        yield d, job, st


def outputs(rundir):
    rundir = Path(rundir)
    job = json.loads((rundir / "job.json").read_text())
    snap = json.loads((STORE / job["hash"] / ".manifest.json").read_text())
    work = rundir / "work"
    out = []
    for p in sorted(work.rglob("*")):
        if not p.is_file() or "__pycache__" in p.parts:
            continue
        rel = p.relative_to(work).as_posix()
        h = sha(p)
        if snap.get(rel) != h:
            out.append({"path": rel, "sha256": h, "bytes": p.stat().st_size, "new": rel not in snap})
    print(json.dumps(out))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list"
    if cmd == "run":
        run(sys.argv[2])
    elif cmd == "list":
        for d, job, st in runs():
            print(json.dumps(dict(id=d.name, project=job.get("project"), cmd=job.get("cmd"), **st)))
    elif cmd == "outputs":
        outputs(sys.argv[2])
    elif cmd == "busy":
        sys.exit(0 if any(st.get("state") == "running" for _, _, st in runs()) else 1)
    elif cmd == "kill":
        d = RUNS / sys.argv[2]
        st = json.loads((d / "status.json").read_text())
        if st.get("pid"):
            try:
                os.killpg(st["pid"], signal.SIGTERM)
            except ProcessLookupError:
                pass
        print("sent SIGTERM to", sys.argv[2])
    else:
        sys.exit("unknown command " + cmd)


if __name__ == "__main__":
    main()
