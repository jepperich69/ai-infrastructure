# rollback.ps1
# Roll back the last N commits in a project's code/ git repo.
# Shows a preview of what will be reverted before doing anything.
#
# Usage:
#   .\rollback.ps1 -Project Pub_AssesTiming_Raoul_TBA          # undo last 1 commit
#   .\rollback.ps1 -Project Pub_AssesTiming_Raoul_TBA -N 3     # undo last 3 commits
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [int]$N = 1
)

. "$PSScriptRoot\config.ps1"
$codeDir = Join-Path $pubRoot "$Project\code"

if (!(Test-Path (Join-Path $codeDir ".git"))) {
    Write-Host "ERR  | code/ is not a git repo: $codeDir"
    Write-Host "       Run init_project_git.ps1 first."
    exit 1
}

$commitCount = [int](git -C $codeDir rev-list HEAD --count 2>$null)
if ($N -ge $commitCount) {
    Write-Host "ERR  | Cannot roll back $N commits -- only $commitCount commit(s) in history"
    exit 1
}

# Preview what will be undone
Write-Host ""
Write-Host "  Rollback preview -- last $N commit(s) to be undone:" -ForegroundColor Yellow
Write-Host ""
git -C $codeDir log --oneline -$N | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
Write-Host ""
Write-Host "  Files that will revert:" -ForegroundColor Yellow
git -C $codeDir diff "HEAD~$N..HEAD" --stat | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
Write-Host ""

$confirm = Read-Host "  Confirm rollback? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled."
    exit 0
}

# Soft reset: keeps files in working tree so nothing is lost, just uncommitted
git -C $codeDir reset --soft "HEAD~$N"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "OK   | Rolled back $N commit(s). Files are unchanged on disk -- changes are now staged." -ForegroundColor Green
    Write-Host "       Review with: git -C ""$codeDir"" diff --cached"
    Write-Host "       Discard all : git -C ""$codeDir"" reset HEAD -- . && git checkout -- ."
    Write-Host "       Re-commit   : git -C ""$codeDir"" commit -m ""your message"""
} else {
    Write-Host "ERR  | Reset failed"
    exit 1
}
