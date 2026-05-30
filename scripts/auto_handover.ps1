﻿# auto_handover.ps1
# Finds the most recently active project (by _ai_log.md modification time)
# and regenerates its handover + AGENTS.md.
#
# Designed to run on a schedule (every 5 min via Task Scheduler).
# Also exposes --register to set up the scheduled task.
#
# Usage:
#   .\auto_handover.ps1              # run once manually
#   .\auto_handover.ps1 --register   # install the scheduled task
#   .\auto_handover.ps1 --unregister # remove the scheduled task
#
param([string]$Action = "")

. "$PSScriptRoot\config.ps1"
$taskName = "ResearchInfra_AutoHandover"

# â"€â"€ Register scheduled task â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
if ($Action -eq "--register") {
    $ps   = (Get-Command powershell.exe).Source
    $script = Join-Path $aiRoot "scripts\auto_handover.ps1"
    $action  = New-ScheduledTaskAction -Execute $ps `
        -Argument "-NonInteractive -WindowStyle Hidden -File `"$script`""
    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -Once `
        -At (Get-Date)
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 2) `
        -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -RunLevel Limited -Force | Out-Null
    Write-Host "OK   | Scheduled task registered: '$taskName' (every 5 min)" -ForegroundColor Green
    Write-Host "      To remove: helpi 19 --unregister  or  auto_handover.ps1 --unregister"
    return
}

# â"€â"€ Unregister â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
if ($Action -eq "--unregister") {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "OK   | Scheduled task removed: '$taskName'" -ForegroundColor Green
    return
}

# â"€â"€ Find most recently active project â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
$candidate = Get-ChildItem $pubRoot -Directory |
    Where-Object { $_.Name -match '^(Pub_|Pro_|PhD_)' } |
    ForEach-Object {
        $log = Join-Path $_.FullName "_ai_log.md"
        if (Test-Path $log) {
            [PSCustomObject]@{ Project = $_.Name; Modified = (Get-Item $log).LastWriteTime }
        }
    } |
    Sort-Object Modified -Descending |
    Select-Object -First 1

if (!$candidate) {
    Write-Host "INFO | No projects with _ai_log.md found -- nothing to do."
    exit 0
}

$age = (Get-Date) - $candidate.Modified
if ($age.TotalHours -gt 24) {
    exit 0
}

$handover = Join-Path $pubRoot "$($candidate.Project)\_handover.html"
if ((Test-Path $handover) -and (Get-Item $handover).LastWriteTime -ge $candidate.Modified) {
    exit 0  # handover already up-to-date
}

& "$PSScriptRoot\generate_handover.ps1" -Project $candidate.Project
