# wake-cellar.ps1 - run on the LAPTOP. Wakes the cellar PC with a Wake-on-LAN magic packet and waits for SSH.
# At home the laptop's own packet is enough; from anywhere it also asks the phone relay (`ssh cellar-relay wake-cellar`,
# Android + Termux + Tailscale, see compute_server/README.md). Waits until SSH answers on the LAN or the Tailscale IP.
# Values (MAC, IPs, port) come from compute_server/local/cellar_config.json (gitignored).
#   .\wake-cellar.ps1            wake (if needed) and wait until the ssh port answers
#   .\wake-cellar.ps1 -Ssh       ... then run `ssh cellar`
# Profile function (PS5 and PS7): function cellar { & "<AI_auto>\compute_server\laptop\wake-cellar.ps1" -Ssh }
param([switch]$Ssh, [int]$TimeoutSec = 150)

$cfgFile = Join-Path $PSScriptRoot '..\local\cellar_config.json'
if (-not (Test-Path $cfgFile)) {
    Write-Host "Missing $cfgFile - copy compute_server\cellar_config.example.json there and fill it in (INSTALL.md Part G)."
    exit 2
}
$cfg = Get-Content $cfgFile -Raw | ConvertFrom-Json
$Mac = $cfg.mac; $LanIp = $cfg.lan_ip; $TsIp = $cfg.tailscale_ip; $Port = [int]$cfg.ssh_port
$Targets = @($cfg.wol_broadcast)
$SshExe = $cfg.ssh_exe

function Test-Port([string]$h, [int]$p, [int]$ms = 700) {
    $c = New-Object System.Net.Sockets.TcpClient
    try { return $c.ConnectAsync($h, $p).Wait($ms) -and $c.Connected } catch { return $false } finally { $c.Dispose() }
}
function Test-Cellar([int]$ms = 700) { (Test-Port $LanIp $Port $ms) -or (Test-Port $TsIp $Port $ms) }

if (Test-Cellar) {
    Write-Host "cellar is awake."
} else {
    $macBytes = $Mac -split '[-:]' | ForEach-Object { [Convert]::ToByte($_, 16) }
    $packet = [byte[]](,0xFF * 6) + ($macBytes * 16)
    $udp = New-Object System.Net.Sockets.UdpClient
    $udp.EnableBroadcast = $true
    foreach ($t in $Targets) { foreach ($p in 9, 7) { try { [void]$udp.Send($packet, $packet.Length, $t, $p) } catch {} } }
    $udp.Close()
    Write-Host "Local magic packet sent (only helps on the home network)."
    & $SshExe -o ConnectTimeout=15 -o BatchMode=yes $cfg.relay_host wake-cellar
    if ($LASTEXITCODE -ne 0) { Write-Host "Phone relay not reachable (phone off / Termux killed / Tailscale off?)." }
    Write-Host -NoNewline "Waiting for SSH"
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while (-not (Test-Cellar 1500)) {
        if ((Get-Date) -gt $deadline) {
            Write-Host "`nNo answer after $TimeoutSec s. Relay failed, or the PC is shut down rather than asleep?"
            exit 1
        }
        Write-Host -NoNewline '.'
    }
    Write-Host "`ncellar is awake."
}
if ($Ssh) { & $SshExe $cfg.ssh_host }
