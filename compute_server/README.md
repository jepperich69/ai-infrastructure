# Compute server ("cellar")

**Status (2026-11-15):** in use. `scripts/cellar.py` (helpi 33) runs jobs end to end: snapshot by hash, tmux run,
keep-awake lock, pull with checksums. Idle sleep, Wake-on-LAN and the phone relay are built; a real
sleep-then-wake cycle is NOT yet tested.

**For any agent (Claude, Codex, Gemini, agy):** this file is the reference. Machine-specific values (MAC, IPs,
host-key fingerprints, licence ID) are in `local/cellar_config.json`, which is gitignored because the repo is
public; this README names the config keys instead of the values. The full build history of the cellar is in
`local/cellar_setup_log.md` (also gitignored). Rebuild procedures: `INSTALL.md` Part G.

## What it is
The music PC in the cellar (16 GB RAM, i7 8 cores / 16 threads, gigabit LAN) doubles as a calculation server for
Gurobi and Python jobs. Windows and the music studio stay as they are. The calculations run in **WSL2 Ubuntu 24.04**,
which the laptop drives over **SSH** (port `ssh_port` = 2222, key login only), on the home LAN or over **Tailscale**
from anywhere. No router port forward.

Why: overnight MIP runs on the laptop compete with OneDrive, Defender and desktop apps for 16 GB, and Claude Code
stops its own background jobs when memory runs critically low (it did so twice on the night of 2026-11-13). Jobs
under `tmux` on the cellar are not subject to that, and the laptop stays free.

## Three machines
| Machine | Role | Replaceable how |
|---|---|---|
| Laptop (Windows) | the only master; drives everything with `cellar.py` | INSTALL.md Part G1: key, ssh config, Tailscale, local config |
| Cellar (Windows + WSL2) | runs jobs; sleeps after 30 idle min | `cellar_setup_instructions.md`, then INSTALL.md Part G2 |
| Phone (Android, Termux) | Wake-on-LAN relay from outside home | `phone/relay-setup.sh`, INSTALL.md Part G3 |

## Design decisions
- **The laptop is the only master.** No OneDrive on the cellar, no DTU file sync. Each job copies the project's
  `code/` (and only the inputs it needs) up over SSH and copies results back into OneDrive.
- **No restricted raw data on the cellar** (e.g. the PostNord data) until the PI decides; a home PC is outside DTU.
- **WSL2 rather than dual boot:** no reboot to switch between music and calculations. RAM capped at 12 GB in
  `.wslconfig`. Avoid heavy solves while recording (audio latency).
- **Python env `pyopt` mirrors the laptop:** Python 3.12, gurobipy 13.0.1, numpy 2.4, scipy 1.16, pandas 2.3.

## Gurobi licence (checked 2026-11-14)
Academic **WLS** licence (ID in `gurobi_license_id`). WLS licences run on any machine with internet; the limit is
**concurrent sessions, 2 by default**, counted across all machines. Each running Python solve process is one session,
and a closed session keeps counting for about 5 minutes. So the laptop and the cellar can each run one job; a third
concurrent one can fail with error 10030 ("too many sessions"). Personal use only, never share or commit the licence
file. A WLS licence runs 90 days and is extended from the DTU network. Fallback: a free named-user academic licence
per machine, activated on the DTU network or VPN.
Sources: support.gurobi.com articles 360040995151, 34672988479633, 360040541251.
The licence file goes to the cellar's `~/gurobi.lic` (mode 600) by scp from the laptop, never typed or synced.

## Access from the laptop
- Key: `~/.ssh/id_ed25519_cellar` (ed25519, no passphrase so jobs run unattended). The same public key is in the
  cellar's and the phone's `authorized_keys`. A new laptop either copies this key pair or authorizes a new one on
  both (INSTALL.md Part G1).
- `~/.ssh/config` needs two blocks (without them ssh never offers the key, because the filename is not a default
  one; the server log then shows "no key offered"):
  ```
  Host cellar
      HostName cellar            # Tailscale MagicDNS name (tailscale_name); works at home and away
      User rich
      Port 2222
      IdentityFile ~/.ssh/id_ed25519_cellar
      IdentitiesOnly yes

  Host cellar-relay
      HostName <relay_ip>        # the phone's Tailscale IP
      Port 8022
      User relay
      IdentityFile ~/.ssh/id_ed25519_cellar
      IdentitiesOnly yes
  ```
- Host keys: compare the first-connect fingerprint against `cellar_host_key` / `relay_host_key` before accepting.
  Windows OpenSSH 9.5 `ssh-keyscan` cannot negotiate with the phone's OpenSSH 10.6; use Git's `ssh-keyscan`.
- Use `C:\WINDOWS\System32\OpenSSH\ssh.exe` / `scp.exe` (`ssh_exe`).
- Git Bash rewrites a remote command that starts with `/` into a Windows path; prefix `MSYS_NO_PATHCONV=1` when
  calling ssh from Git Bash. `cellar.py` (plain Python subprocess) is not affected.
- **Codex:** its workspace sandbox blocks outbound ssh ("Connection refused"), even with sandbox network access on.
  Codex must run `cellar.py` / ssh with escalation (approval outside the sandbox). See `known_issues.md`.
- `python scripts\cellar.py doctor` checks all of the above without waking anything.

## Running jobs: `scripts/cellar.py` (helpi 33)
In any agent: "run X on the cellar". Commands: `run --project DIR [--src code] -- CMD`, `jobs`, `log RUNID`,
`pull RUNID`, `kill RUNID`, `env`, `wake`, `sleep`, `status`, `install`, `doctor`.
- **Snapshot by hash.** Every file in `DIR/src` (minus `__pycache__`, `remote_runs`, `.git`, `*.pyc`) is hashed; the
  job hash is SHA-256 of the sorted manifest. `~/store/<hash>/` holds each snapshot once (with `.manifest.json`);
  each run gets its own copy in `~/runs/<runid>/work`, so a script that appends to its CSV resumes from the laptop's state.
- **Run.** `~/bin/cellar_job.py run` (installed from `remote/cellar_job.py`, stdlib only) runs CMD in tmux session
  `job-<runid>` with the pyopt env first on PATH, writes `status.json` (state, start/end, exit code, wall and CPU
  seconds, peak RSS) and `run.log`, and holds a keep-awake request while the `RUNNING` flag exists.
- **Pull.** New or changed files (against the snapshot), `run.log` and `manifest.json` go to
  `DIR/src/remote_runs/<runid>/`; each file's SHA-256 is checked. `DIR/_remote_runs.csv` gets one row per run.
  Results never overwrite the project's own files; copy them in deliberately.
- **Fingerprints.** Each run records both pyopt pip-freeze fingerprints, key versions and both jr_optlib commits.
  2026-11-14: gurobipy 13.0.1, scipy 1.16.3, pandas 2.3.3, sympy 1.14.0 match; numpy 2.4.1 vs 2.4.6, networkx
  3.6.1 vs 3.7, matplotlib 3.10.8 vs 3.11.2 differ (laptop vs cellar).

## Power: idle sleep, keep-awake, wake
- The cellar sleeps after `idle_sleep_min` (30) idle minutes on AC; hibernate is off. The NIC has Wake on Magic
  Packet on and Wake on pattern match off (avoids random wakes).
- **Keep-awake watchdog** (`cellar_side/cellar_watchdog.ps1`, scheduled task "Cellar sleep watchdog", at logon,
  hidden, not elevated): every 30 s it runs `/usr/local/bin/cellar-busy` in WSL (`cellar_side/cellar-busy.sh`) and
  holds ES_SYSTEM_REQUIRED while there is an SSH session on :2222, a tmux session, 1-min load > 0.7, WSL not
  answering (fail safe), or < 15 min since boot/resume. Check with `powercfg /requests`.
- **Wake from home:** a magic packet to `mac` on `wol_broadcast`, UDP 9 and 7.
- **Wake from anywhere:** the phone on the home Wi-Fi relays the packet. `ssh cellar-relay wake-cellar` prints
  "relay: magic packet for <mac> sent (4/4)". Phone: Termux sshd on port 8022, user `relay`, key only,
  Tailscale with Always-on VPN, Termux:Boot restarts sshd after a reboot.
- `laptop/wake-cellar.ps1`: local packet + relay, waits up to 150 s for the ssh port on `lan_ip` or `tailscale_ip`;
  `-Ssh` then logs in. The PowerShell function `cellar` (PS5 and PS7 profiles) runs it with `-Ssh`.
- `cellar.py` does the same before every command: local packet every 5 s, relay once, again after 60 s.
- **Phone settings that keep the relay alive (fixed 2026-11-15).** On 2026-11-15 the phone had rebooted at 02:04
  (likely a night-time system update) and Android stopped Tailscale about an hour later, so the relay was down.
  After the settings below, a reboot with no touching brings back Tailscale (about 60 s) and sshd by itself.
  OnePlus OxygenOS, Danish UI (search the term in Indstillinger if the path differs):
  | Setting | Where (Danish UI) | Value |
  |---|---|---|
  | Always-on VPN | Indstillinger > search `VPN` > gear next to Tailscale > **Permanent VPN** | on |
  | Block without VPN | same page, **Bloker forbindelser uden VPN** | **off** (else the phone locks itself out) |
  | Battery, all three apps | Apps > Administration af apps > [app] > **Batteriforbrug**: **Tillad baggrundsaktivitet**, **Kør tjeneste i forgrunden** | on |
  | Auto start | Termux:Boot: **Kør ved opstart**; also **Afhold telefonen fra at gå i dvale** (wake lock) | on |
  | Recents | recent apps > three dots on Termux and Tailscale > **Lås** | locked |
  | System updates | System og opdateringer > Softwareopdatering > gear > automatic download / night install | off (update by hand) |
  | Play Store auto-update | keep on (Tailscale needs to stay current) | on |
  | Bekræft apps via USB | Indstillinger for udviklere | on (was off during setup) |
  Changing an app's battery settings force-stops it: afterwards open Termux and run `sshd`, or restart the phone.
  At home the laptop's local packet works even when the relay is down.

## Tests and benchmark (2026-11-14)
- `test_fishbone_mip_soft.py` (Pub_DistributionNetworks_TBA): 10/10 pass on the cellar, values identical to the laptop.
- Same MIP (night_capacity n=10, hard cap 120k, diesel human, gap 1e-3, 6 threads): laptop 791 s, cellar **512 s**,
  same optimum 109,801; about 1.5x faster at equal threads. Peak memory 372 MB; 4.7 cores busy on average.
- Threads: 7 threads 606 s, 14 threads 623 s, against 512 s at 6. Use 6-8 threads per Gurobi job and leave the rest
  to licence-free work (Monte Carlo, MCMC, numba).
- Parallel solves sharing one licence session: dropped. Gurobi environments are not thread-safe, so each thread
  needs its own environment, and with WLS each environment is a session (2 in total).
- numba 0.68.1 is in pyopt on both machines. JAX 0.12 (CPU) is in a separate env `jax` on the cellar only
  (`~/miniforge3/envs/jax`), so pyopt keeps its numpy; used by Pub_FunctionClass_SR_TBA.

## jr_optlib on the cellar
- Clone at `~/src/jr_optlib` (public GitHub repo, https, no key), editable install in `~/miniforge3/envs/pyopt`
  with extras `oracles,population,fast-sampling,transport-lp,setcover-gurobi`.
- Update: push from the laptop, then `ssh cellar 'git -C ~/src/jr_optlib pull --ff-only'`. Only pushed commits
  reach the cellar. For paper runs, pin a SHA and record it.
- `pulp` must stay < 4 (pinned in pyproject since 7f6737b): newer pulp rejects the `lowBound` keyword.
- Tests at 7f6737b: 84 pass, 45 skip, 15 fail; every failure is an old-copy differential that loads paper code from
  Windows OneDrive paths; the library itself is fine. Laptop: 148 pass.

## Files
| Path | What | In git |
|---|---|---|
| `cellar_setup_instructions.md` | checklist for a Claude Code session ON the cellar PC (rebuild from scratch) | yes |
| `cellar_config.example.json` | template for the local config | yes |
| `local/cellar_config.json` | real values: MAC, IPs, host keys, paths, licence ID | **no** (gitignored) |
| `local/cellar_setup_log.md` | build log of the current cellar (2026-11-14) | **no** |
| `remote/cellar_job.py` | cellar-side job helper; `cellar.py` reinstalls it when its hash changes | yes |
| `cellar_side/cellar_watchdog.ps1`, `cellar-busy.sh` | keep-awake watchdog on the cellar's Windows side | yes |
| `laptop/wake-cellar.ps1` | wake + wait (+ ssh) from the laptop | yes |
| `phone/relay-setup.sh` | turns an Android phone with Termux into the wake relay | yes |
| `../scripts/cellar.py` | the laptop tool (helpi 33) | yes |

`local/` is synced by OneDrive on the laptop but never pushed. Keep a copy somewhere you can reach from a new
laptop (OneDrive is enough); without it, rebuild it from the template plus the setup log.

## Open
1. One real sleep-then-wake test (PI: Start > Power > Sleep on the cellar, then `cellar` from the laptop, away from home).
2. Make the old-copy jr_optlib tests skip when paper folders are missing.
