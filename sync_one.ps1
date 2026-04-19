# sync_one.ps1
# Pull the latest from Overleaf for a single project.
#
# Usage:
#   .\sync_one.ps1 -Project Pub_AssesTiming_Raoul_TBA
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

. "$PSScriptRoot\config.ps1"
$jsonPath = "$aiRoot\projects.json"

$projects = Get-Content $jsonPath | ConvertFrom-Json
$match    = $projects | Where-Object { $_.name -eq $Project } | Select-Object -First 1

if (!$match) {
    Write-Host "ERR  | '$Project' not found in projects.json"
    exit 1
}

$path   = $match.path
$branch = $match.branch

if (!(Test-Path $path)) {
    Write-Host "ERR  | Path not found: $path"
    exit 1
}

Write-Host "Syncing: $Project"
Write-Host "Path   : $path"
Write-Host "Branch : $branch"
Write-Host ""

# Pre-check remote SHA
$remoteRef = git -C $path ls-remote origin HEAD 2>$null
if ($remoteRef) {
    $remoteSHA = ($remoteRef -split '\s+')[0].Trim()
    $localSHA  = (git -C $path rev-parse HEAD 2>$null).Trim()
    if ($remoteSHA -eq $localSHA) {
        # Still check for local uncommitted changes
        git -C $path add . 2>$null
        git -C $path diff --cached --quiet 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "OK   | Already up to date with Overleaf"
            exit 0
        }
        $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
        git -C $path commit --quiet -m "Auto-backup $ts"
        Write-Host "OK   | No Overleaf changes; local edits backed up"
        exit 0
    }
}

# Pull
git -C $path pull --quiet origin $branch 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERR  | Pull failed"
    exit 1
}

git -C $path add . 2>$null
git -C $path diff --cached --quiet 2>$null
if ($LASTEXITCODE -ne 0) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
    git -C $path commit --quiet -m "Auto-backup $ts"
    Write-Host "OK   | Pulled and backed up local changes"
} else {
    Write-Host "OK   | Pulled from Overleaf"
}
