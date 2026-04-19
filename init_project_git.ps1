# init_project_git.ps1
# One-time setup: initialise a git repo in a project's code/ folder.
#
# Usage:
#   .\init_project_git.ps1 -Project Pub_AssesTiming_Raoul_TBA
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

. "$PSScriptRoot\config.ps1"
$codeDir  = Join-Path $pubRoot "$Project\code"

if (!(Test-Path $codeDir)) {
    Write-Host "ERR  | code/ folder not found: $codeDir"
    exit 1
}

if (Test-Path (Join-Path $codeDir ".git")) {
    Write-Host "OK   | Already a git repo: $codeDir"
    exit 0
}

# .gitignore
$gitignore = @"
__pycache__/
*.pyc
*.pyo
*.pyd
.ipynb_checkpoints/
.env
*.egg-info/
dist/
build/
"@

Set-Content -Path (Join-Path $codeDir ".gitignore") -Value $gitignore

# Init and first commit
git -C $codeDir init --quiet
git -C $codeDir add -A
git -C $codeDir commit --quiet -m "init: initial commit ($Project)"

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK   | Git repo initialised: $codeDir"
} else {
    Write-Host "ERR  | git commit failed"
    exit 1
}

# Create a blank session log in the project root
$projectRoot = Join-Path $pubRoot $Project
$logPath     = Join-Path $projectRoot "_ai_log.md"

if (!(Test-Path $logPath)) {
    $header = @"
# AI Session Log â€” $Project

<!-- Claude updates this file at the start and end of every working session. -->
<!-- Format: one ## Session block per date, with Goal / Changes / Outcome / Next steps. -->

"@
    Set-Content -Path $logPath -Value $header
    Write-Host "OK   | Session log created: $logPath"
}
