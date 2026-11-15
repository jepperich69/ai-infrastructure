# Setup: turn this PC into a calculation server (WSL2 Ubuntu), driven by SSH from the laptop

You are Claude Code (or another agent) running on the user's music PC (Windows). Set up a Linux calculation
server inside WSL2 that an agent session on the user's laptop will drive over SSH, on the home LAN or over
Tailscale. Background and design: `README.md` in this folder. The first build (2026-11-14) is logged in
`local/cellar_setup_log.md` on the laptop; this checklist already includes what that build learned.
Keep a progress log as you go (e.g. `C:\Users\<windows user>\cellar_setup_log.md`) and copy it to the laptop at the end.

## Ground rules (read first)
- This PC is ALSO the user's music studio. Do not uninstall, update or reconfigure audio software, drivers,
  ASIO settings or DAW settings. Do not change BIOS settings. Ask before any reboot.
- Do NOT install or sign in to OneDrive here, and do not copy any DTU/OneDrive files. Code and data are
  pushed from the laptop per job; the laptop stays the master copy.
- Never put the Gurobi licence file, its keys, or any password in a file other than ~/gurobi.lic, and
  never print the licence secrets in the chat.
- Ask the user before any step that needs admin rights and before opening a firewall port.
- Report at the end with the "REPORT BACK" block below, filled in.

## Step 0. Check the machine
1. Windows edition and build: `[System.Environment]::OSVersion` or `winver`. Mirrored WSL networking
   (step 3) needs Windows 11 22H2 or later. If this is Windows 10, say so and use the fallback in step 3.
2. RAM, CPU cores and free disk: `Get-CimInstance Win32_ComputerSystem`, `Get-CimInstance Win32_Processor`,
   `Get-PSDrive C`. Need at least 40 GB free on the drive WSL goes on.
3. Virtualization enabled: `systeminfo` -> "Virtualization Enabled In Firmware: Yes" (or Task Manager >
   Performance > CPU). If it is off, STOP and tell the user (it is a BIOS switch; the user decides).

## Step 1. Network and power (Windows side)
1. Note the PC's LAN IPv4 address and adapter (`Get-NetIPAddress -AddressFamily IPv4`). Tell the user to
   give it a fixed DHCP reservation in the router (the user does this in the router web page).
2. Power for now: no sleep or hibernate on AC while setting up (admin):
   `powercfg /change standby-timeout-ac 0` and `powercfg /change hibernate-timeout-ac 0`.
   Step 10 later turns idle sleep back on, with a watchdog that keeps the PC awake during jobs.
   Do not change anything else in the power plan (audio may depend on it).
3. Note the MAC address of the wired adapter (`Get-NetAdapter`) for Wake-on-LAN.

## Step 2. Install WSL2 + Ubuntu 24.04 (admin)
1. `wsl --install -d Ubuntu-24.04` (reboot if asked, after asking the user). On first start create the
   Linux user `rich` with a password the user chooses (the user types it; do not store it).
2. Check: `wsl -l -v` shows Ubuntu-24.04, VERSION 2. Run `wsl --update` once.
3. If `wsl --install` only answers "WSL is not installed" (happened in 2026-11): enable the features by hand
   (`dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart` and the same for
   `VirtualMachinePlatform`), reboot (ask first), install the Microsoft-signed WSL MSI from
   github.com/microsoft/WSL/releases, then `wsl --set-default-version 2` and install Ubuntu-24.04 again.
   If first-run user creation fails, create `rich` as root (`useradd -m -G sudo rich`, the user sets the password)
   and put `[user] default=rich` in `/etc/wsl.conf`.

## Step 3. Configure WSL: memory cap, mirrored networking, no idle shutdown
1. Create `C:\Users\<windows user>\.wslconfig` with:
   ```
   [wsl2]
   memory=12GB
   processors=<number of logical cores minus 2>
   swap=4GB
   networkingMode=mirrored
   vmIdleTimeout=-1

   [experimental]
   hostAddressLoopback=true
   ```
   (12 GB leaves ~4 GB for Windows; the user can lower it when recording.)
2. Inside Ubuntu, `/etc/wsl.conf`:
   ```
   [boot]
   systemd=true
   ```
3. `wsl --shutdown`, start Ubuntu again, check that `free -g` shows ~12 GB and `systemctl` works.
4. Fallback if mirrored networking is not available (Windows 10): leave networkingMode out, and set up a
   port proxy from Windows port 2222 to the WSL IP instead (`netsh interface portproxy add v4tov4
   listenport=2222 listenaddress=0.0.0.0 connectport=2222 connectaddress=<wsl ip>`). The WSL IP can change
   at each start, so the keepalive task in step 5 must refresh it. Report which route you used.

## Step 4. SSH server inside Ubuntu, key login only
1. `sudo apt update && sudo apt -y upgrade && sudo apt -y install openssh-server tmux rsync htop build-essential git`
2. Use port 2222 (avoids clashing with any Windows SSH server). Create `/etc/ssh/sshd_config.d/10-cellar.conf`:
   ```
   Port 2222
   PasswordAuthentication no
   KbdInteractiveAuthentication no
   PermitRootLogin no
   AllowUsers rich
   ```
   On Ubuntu 24.04 sshd may be socket-activated: if `ss` does not show 2222 after a restart, run
   `sudo systemctl disable --now ssh.socket && sudo systemctl enable --now ssh.service`.
3. Authorize the laptop's key: put the laptop's public key (`~/.ssh/id_ed25519_cellar.pub` on the laptop;
   the user pastes it) in `/home/rich/.ssh/authorized_keys` (dir 700, file 600, owned by rich). The key in use
   since 2026-11-14 is:
   ```
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7kyyUt34iBFR9MJfvp7gtkJ2A4WhnU8KMAEFBH/UGb laptop-claude-to-cellar
   ```
   If the laptop has a new key, use that one instead (ask the user).
4. `sudo systemctl enable --now ssh` and check `ss -tlnp | grep 2222`.
5. Windows firewall (admin; ask first). Allow inbound TCP 2222 from the local subnet only:
   `New-NetFirewallRule -DisplayName "WSL SSH 2222 (LAN)" -Direction Inbound -Protocol TCP -LocalPort 2222 -RemoteAddress LocalSubnet -Action Allow`
   With mirrored networking, also allow it through the Hyper-V firewall:
   `New-NetFirewallHyperVRule -Name WSLSSH2222 -DisplayName "WSL SSH 2222" -Direction Inbound -VMCreatorId '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -Protocol TCP -LocalPorts 2222 -RemoteAddresses <LAN subnet, e.g. 192.168.1.0/24>`
6. Do NOT forward port 2222 in the router. Access from outside home goes through Tailscale (step 9).

## Step 5. Keep WSL up after a Windows reboot
WSL only starts when something calls it. Create a Windows scheduled task "WSL keepalive" that runs at
log-on of the user: program `conhost.exe`, arguments
`--headless wsl.exe -d Ubuntu-24.04 --exec /bin/sh -c "sleep infinity"` (no console window), run level Limited,
no time limit, restart 3 times at 1-minute intervals. (With systemd on, sshd then starts automatically.) Tell the user that the Windows
user must be logged in for it to run (auto-login is the user's choice; do not configure it).

## Step 6. Python environment (inside Ubuntu, as user rich)
1. Install Miniforge in `~/miniforge3` (from github.com/conda-forge/miniforge releases, the
   Linux-x86_64 installer, batch mode `-b`). Do not touch the system Python.
2. Create env `pyopt` matching the laptop:
   ```
   ~/miniforge3/bin/mamba create -n pyopt -y python=3.12 numpy=2.4 scipy=1.16 pandas=2.3 matplotlib networkx sympy pytest
   ~/miniforge3/envs/pyopt/bin/pip install gurobipy==13.0.1 cvxpy clarabel
   ```
   Laptop versions: Python 3.12.12, gurobipy 13.0.1, numpy 2.4.1, scipy 1.16.3, pandas 2.3.3, networkx 3.6.1.
3. Jobs use `~/miniforge3/envs/pyopt/bin/python`. Add `export OPENBLAS_NUM_THREADS=1` and
   `export MKL_NUM_THREADS=1` (the solvers do their own threading) at the TOP of `~/.bashrc`, before Ubuntu's
   "if not interactive, return" line, and also to `~/.profile`; otherwise non-interactive ssh commands miss them.
   Use the versioned Miniforge asset names; the unversioned `latest/download/...sha256` URL returns 404.
4. Also: `~/miniforge3/envs/pyopt/bin/pip install numba`. Other envs (e.g. `jax`) go in separate conda envs, so
   pyopt keeps its numpy.
5. Folders: `mkdir -p ~/jobs ~/results`. `cellar.py` uses `~/store`, `~/runs` and `~/bin` (it creates them).
6. jr_optlib: `git clone https://github.com/jepperich69/jr_optlib.git ~/src/jr_optlib`, then
   `~/miniforge3/envs/pyopt/bin/pip install -e "~/src/jr_optlib[oracles,population,fast-sampling,transport-lp,setcover-gurobi]"`.

## Step 7. Gurobi licence
Do NOT obtain or type the licence here. The laptop session will copy the existing WLS academic licence
to `~/gurobi.lic` by scp once SSH works. Only add `export GRB_LICENSE_FILE=$HOME/gurobi.lic` to `~/.bashrc`
(and to `~/.profile`, so non-interactive SSH commands see it). The licence allows 2 concurrent sessions
across all machines; nothing to configure here.

## Step 8. Self-test (no Gurobi solve yet)
1. From Windows on this PC: `ssh -p 2222 rich@localhost` must REFUSE password login (good: key only).
2. `~/miniforge3/envs/pyopt/bin/python -c "import numpy, scipy, pandas, gurobipy; print(gurobipy.gurobi.version())"` prints (13, 0, 1).
3. `tmux new -d -s test 'sleep 30'` then `tmux ls` works.
4. `nproc`, `free -g`, `df -h ~` for the report.

## Step 9. Tailscale (access from outside home; the user signs in)
1. Inside Ubuntu, install Tailscale from pkgs.tailscale.com (Ubuntu noble, stable) and enable `tailscaled`.
2. `sudo tailscale up --hostname=cellar`; the user opens the login URL and signs in to their tailnet.
3. The user disables key expiry for `cellar` in the Tailscale admin console.
4. sshd on 0.0.0.0:2222 already covers `tailscale0`. Note the Tailscale IP and the server host key fingerprint
   (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) for the report.

## Step 10. Idle sleep, Wake-on-LAN and the keep-awake watchdog (admin; ask first)
1. NIC (the wired adapter from step 1): Wake on Magic Packet ON, Wake on pattern match OFF
   (`Set-NetAdapterAdvancedProperty` / Device Manager > Power Management: "Only allow a magic packet").
2. `powercfg /change standby-timeout-ac 30` (hibernate stays 0). Unhide and raise the unattended-wake sleep timeout
   (setting 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0) to 600 s, so a WoL wake does not fall asleep after 2 minutes.
3. Install `cellar_side/cellar-busy.sh` as `/usr/local/bin/cellar-busy` (mode 755) in Ubuntu.
4. Copy `cellar_side/cellar_watchdog.ps1` to a folder the Windows user can write (e.g. `C:\Users\<windows user>\`)
   and create `logs\` next to it; the script logs state changes to `logs\cellar_watchdog.log`. Scheduled task "Cellar sleep watchdog": at logon of the user, not elevated,
   `conhost.exe --headless powershell.exe -NoProfile -ExecutionPolicy Bypass -File <path>\cellar_watchdog.ps1`.
5. Check: start a tmux session in WSL; within a minute `powercfg /requests` shows powershell.exe under SYSTEM.
6. BIOS: if WoL fails later, ErP / Deep Sleep may need turning off. That is the user's decision; do not change BIOS.

## Step 11. Phone relay (only if the phone is also being replaced)
The relay is an Android phone on the home Wi-Fi with Tailscale and Termux. It is set up with
`phone/relay-setup.sh`; the steps are in `INSTALL.md` Part G3. A new cellar with a new MAC only needs the relay's
`wake-cellar` regenerated: `cat <laptop pubkey> | sh relay-setup.sh <new MAC> <broadcast>` in Termux.

## REPORT BACK (give the user this filled block to paste to the laptop session)
```
CELLAR READY
lan_ip:            <x.x.x.x>   (router reservation done? yes/no)
ssh:               port 2222, user rich, key-only, mirrored networking yes/no (or portproxy)
windows build:     <...>
wsl:               Ubuntu-24.04, WSL2, memory cap <..> GB, cores <..>, disk free <..> GB
python:            ~/miniforge3/envs/pyopt/bin/python, versions <python/gurobipy/numpy/scipy>
keepalive task:    yes/no; auto-login: user's choice <yes/no>
firewall rules:    <names>
mac / broadcast:   <wired adapter MAC> / <LAN broadcast>
tailscale:         <name> / <100.x IP>, key expiry disabled yes/no
host key:          ED25519 SHA256:<...>
sleep + watchdog:  idle sleep <..> min, watchdog task yes/no, powercfg /requests check yes/no
issues / not done: <...>
```
