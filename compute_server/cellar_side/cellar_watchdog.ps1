# cellar_watchdog.ps1 - keeps the PC awake while the cellar (WSL) is in use, lets it sleep otherwise.
# Runs hidden at logon of the cellar's Windows user via the "Cellar sleep watchdog" scheduled task (conhost --headless).
# Busy = SSH session on :2222, or a tmux session, or 1-min load > $LoadThreshold, or within $GraceMin after boot/resume.
# While busy it holds ES_SYSTEM_REQUIRED (visible in `powercfg /requests` as SYSTEM: powershell.exe).
param([int]$IntervalSec = 30, [int]$GraceMin = 15, [double]$LoadThreshold = 0.7)

$log = Join-Path $PSScriptRoot 'logs\cellar_watchdog.log'   # logs\ must be writable by the logon user (task is not elevated)
Add-Type -Namespace Cellar -Name Power -MemberDefinition @'
[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);
'@
$ES_CONTINUOUS = [uint32]'0x80000000'; $ES_SYSTEM_REQUIRED = [uint32]'0x00000001'

function Write-Log($msg) {
    try {
        if ((Test-Path $log) -and (Get-Item $log).Length -gt 1MB) { Move-Item $log "$log.old" -Force }
        Add-Content -Path $log -Value ("{0:yyyy-MM-dd HH:mm:ss}  {1}" -f (Get-Date), $msg) -Encoding utf8
    } catch {}
}

function Get-CellarStatus {
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo.FileName = 'C:\Windows\System32\wsl.exe'
    $p.StartInfo.Arguments = '-d Ubuntu-24.04 --exec /usr/local/bin/cellar-busy'
    $p.StartInfo.UseShellExecute = $false
    $p.StartInfo.RedirectStandardOutput = $true
    $p.StartInfo.CreateNoWindow = $true
    [void]$p.Start()
    $out = $p.StandardOutput.ReadToEndAsync()
    if (-not $p.WaitForExit(20000)) { try { $p.Kill() } catch {}; return $null }
    $s = @{}
    foreach ($kv in ($out.Result.Trim() -split '\s+')) { $k, $v = $kv -split '=', 2; if ($k) { $s[$k] = $v } }
    if (-not $s.ContainsKey('load')) { return $null }
    return $s
}

$graceUntil = (Get-Date).AddMinutes($GraceMin)
$lastTick = Get-Date
$held = $null
Write-Log "watchdog started (interval ${IntervalSec}s, grace ${GraceMin}min, load > $LoadThreshold)"

while ($true) {
    $now = Get-Date
    if (($now - $lastTick).TotalSeconds -gt ($IntervalSec + 60)) {
        $graceUntil = $now.AddMinutes($GraceMin)
        Write-Log ("resume detected (gap {0:n0}s), grace until {1:HH:mm}" -f ($now - $lastTick).TotalSeconds, $graceUntil)
    }
    $lastTick = $now

    $s = Get-CellarStatus
    $reasons = @()
    if ($null -eq $s) { $reasons += 'wsl-unresponsive' }   # fail safe: stay awake, never sleep mid-job by accident
    else {
        if ([int]$s.ssh -gt 0) { $reasons += "ssh=$($s.ssh)" }
        if ([int]$s.tmux -gt 0) { $reasons += "tmux=$($s.tmux)" }
        if ([double]::Parse($s.load, [Globalization.CultureInfo]::InvariantCulture) -gt $LoadThreshold) { $reasons += "load=$($s.load)" }
    }
    if ($now -lt $graceUntil) { $reasons += 'grace' }

    $busy = $reasons.Count -gt 0
    if ($busy) { [void][Cellar.Power]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) }
    else       { [void][Cellar.Power]::SetThreadExecutionState($ES_CONTINUOUS) }
    if ($busy -ne $held) {
        if ($busy) { Write-Log ("AWAKE  (" + ($reasons -join ', ') + ")") } else { Write-Log "IDLE   (normal sleep timer applies)" }
        $held = $busy
    }
    Start-Sleep -Seconds $IntervalSec
}
