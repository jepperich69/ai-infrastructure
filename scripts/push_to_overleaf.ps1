# push_to_overleaf.ps1
# Push local edits in an Overleaf_source repo back to Overleaf.
#
# Usage:
#   From anywhere:    .\push_to_overleaf.ps1 -Project Pub_AssesTiming_Raoul_TBA
#   From repo folder: .\push_to_overleaf.ps1
#
param(
    [Parameter(Mandatory=$false)]
    [string]$Project
)

. "$PSScriptRoot\config.ps1"
$jsonPath = "$aiRoot\projects.json"

# ---------------------------------------------------------------
# Resolve repo path and branch
# ---------------------------------------------------------------
if ($Project) {
    $projects = Get-Content $jsonPath | ConvertFrom-Json
    $match    = $projects | Where-Object { $_.name -eq $Project } | Select-Object -First 1
    if (-not $match) {
        Write-Host "ERR  | Project '$Project' not found in projects.json"
        Write-Host "       Available names:"
        ($projects | Select-Object -ExpandProperty name | Sort-Object -Unique) -split "`n" | ForEach-Object { Write-Host "         $_" }
        exit 1
    }
    $repoPath = $match.path
    $branch   = $match.branch
} else {
    $cwd = (Get-Location).Path

    $projectName = ""
    $pubPrefix = "$pubRoot\"
    if ($cwd.StartsWith($pubPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative    = $cwd.Substring($pubPrefix.Length)
        $projectName = ($relative -split '[\\/]')[0]
        if ($projectName -notmatch '^(Pub_|Pro_|PhD_)') { $projectName = '' }
    }

    if ($projectName) {
        $projectRoot = Resolve-ProjectRoot $projectName
        $overleafDir = Join-Path $projectRoot 'Overleaf_source'
        if (Test-Path (Join-Path $overleafDir '.git')) {
            $repoPath = $overleafDir
            $branch   = git -C $repoPath rev-parse --abbrev-ref HEAD 2>$null
        } else {
            Write-Host "ERR  | Overleaf_source git repo not found for project: $projectName"
            Write-Host "       Expected: $overleafDir"
            exit 1
        }
    } else {
        $repoPath = $cwd
        $branch   = git -C $repoPath rev-parse --abbrev-ref HEAD 2>$null
    }

    if (-not $branch -or $LASTEXITCODE -ne 0) {
        Write-Host "ERR  | Not inside a git repository or project root: $cwd"
        exit 1
    }
}
if (!(Test-Path $repoPath)) {
    Write-Host "ERR  | Path not found: $repoPath"
    exit 1
}

Write-Host "Repo : $repoPath"
Write-Host "Branch: $branch"

# ---------------------------------------------------------------
# Sync AI meta-files from project root into Overleaf_source
# ---------------------------------------------------------------
$projectRoot = Split-Path $repoPath -Parent
$aiMetaFiles = @('_ai_log.md', '_handover.html', '_handover.json')
foreach ($f in $aiMetaFiles) {
    $src = Join-Path $projectRoot $f
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $repoPath $f) -Force
    }
}

# ---------------------------------------------------------------
# Stage and check for changes / existing unpushed commits
# ---------------------------------------------------------------
$hasStagedChanges = $true
git -C $repoPath add . 2>&1 | Out-Null
git -C $repoPath diff --cached --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $hasStagedChanges = $false
    git -C $repoPath fetch origin $branch 2>&1 | Out-Null
    $ahead = git -C $repoPath rev-list --count origin/$branch..HEAD 2>$null
    if ($ahead -gt 0) {
        Write-Host "INFO | Working tree is clean, but branch has $ahead unpushed commit(s)"
    } else {
        Write-Host "OK   | Nothing to push - working tree is clean"
        exit 0
    }
}

if ($hasStagedChanges) {
    # Show what will be committed
    Write-Host ""
    Write-Host "Changes to push:"
    git -C $repoPath diff --cached --name-status
    Write-Host ""

    # ---------------------------------------------------------------
    # Commit
    # ---------------------------------------------------------------
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git -C $repoPath commit --quiet -m "Local edits $timestamp"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERR  | Commit failed"
        exit 1
    }
}

# ---------------------------------------------------------------
# Pull before push (rebase local commits on top of remote)
# ---------------------------------------------------------------
Write-Host "Pulling remote changes before push..."
git -C $repoPath fetch origin $branch 2>&1 | Out-Null

$behind = git -C $repoPath rev-list --count HEAD..origin/$branch 2>$null
if ($behind -gt 0) {
    Write-Host "INFO | Remote has $behind new commit(s) - rebasing your changes on top..."
    git -C $repoPath rebase origin/$branch 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "CONFLICT | Rebase stopped - you and a co-author edited the same lines."
        Write-Host "           Open the file(s) listed above, resolve the conflict markers,"
        Write-Host "           then run:"
        Write-Host "             git -C `"$repoPath`" rebase --continue"
        Write-Host "           and push again when done."
        exit 1
    }
    Write-Host "OK   | Rebase clean - your changes are on top of co-author's commits"
} else {
    Write-Host "OK   | Remote is up to date, no pull needed"
}

# ---------------------------------------------------------------
# Push
# ---------------------------------------------------------------
git -C $repoPath push origin $branch
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK   | Pushed to Overleaf"
} else {
    Write-Host "ERR  | Push failed - check remote access / SSH key"
    exit 1
}
