# snapshot.ps1  --  Git-tag the full Overleaf_source/ as a named version snapshot.
# Captures everything: .tex, .bib, figures, style files, subdirectories.
#
# Usage:
#   snapshot.ps1 -Project Pub_XXX            # auto-increments (V1, V2, ...)
#   snapshot.ps1 -Project Pub_XXX -Tag V2
#   snapshot.ps1 -Project Pub_XXX -Tag "V2-before-reviewer-cuts"

param(
    [string]$Project = "",
    [string]$Tag     = ""
)

$aiRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$pubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"

# ── Resolve project ───────────────────────────────────────────────────────────
if (-not $Project) {
    $parts   = (Get-Location).Path -split '\\'
    $Project = ($parts | Where-Object { $_ -match '^(Pub_|Pro_|PhD_)' } | Select-Object -Last 1)
    if (-not $Project) { Write-Error "Cannot detect project from CWD. Use -Project."; exit 1 }
}

# Use projects.json path (handles non-standard subfolder structures)
$projData = Get-Content "$aiRoot\projects.json" | ConvertFrom-Json
$entry    = $projData | Where-Object { $_.name -eq $Project } | Select-Object -First 1
$src      = if ($entry) { $entry.path } else { "$pubRoot\$Project\Overleaf_source" }

if (-not (Test-Path (Join-Path $src ".git"))) {
    Write-Error "No git repo at '$src'. Is '$Project' registered in projects.json?"
    exit 1
}

# ── Auto-detect next version number ──────────────────────────────────────────
if (-not $Tag) {
    $existing = @(git -C $src tag -l "snapshot-v*" 2>$null)
    $maxN = 0
    foreach ($t in $existing) {
        if ($t -match 'snapshot-v(\d+)') { $maxN = [Math]::Max($maxN, [int]$Matches[1]) }
    }
    $Tag = "V$($maxN + 1)"
    Write-Host "  Auto-version: $Tag" -ForegroundColor DarkGray
}

$tagName = ("snapshot-" + $Tag).ToLower() -replace '[^a-z0-9\-]', '-'

# ── Guard: duplicate ──────────────────────────────────────────────────────────
if (@(git -C $src tag -l $tagName 2>$null).Count -gt 0) {
    Write-Error "Tag '$tagName' already exists. Use a different label."
    exit 1
}

# ── Abort if working tree is dirty ────────────────────────────────────────────
$dirty = @(git -C $src status --porcelain 2>$null)
if ($dirty.Count -gt 0) {
    Write-Host ""
    Write-Host "  ABORT: uncommitted changes in '$Project'." -ForegroundColor Red
    Write-Host "  A snapshot should capture a known state, not accidental edits." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Uncommitted files:" -ForegroundColor Yellow
    foreach ($line in $dirty) { Write-Host "    $line" -ForegroundColor DarkYellow }
    Write-Host ""
    Write-Host "  Option 1 — commit them (recommended):" -ForegroundColor DarkGray
    Write-Host "    git -C `"$src`" add <file>" -ForegroundColor DarkGray
    Write-Host "    git -C `"$src`" commit -m `"your message`"" -ForegroundColor DarkGray
    Write-Host "  Option 2 — stash them (reversible):" -ForegroundColor DarkGray
    Write-Host "    git -C `"$src`" stash" -ForegroundColor DarkGray
    Write-Host "    # then snapshot, then: git -C `"$src`" stash pop" -ForegroundColor DarkGray
    Write-Host "  Option 3 — discard them (PERMANENT, cannot be undone):" -ForegroundColor DarkGray
    Write-Host "    git -C `"$src`" checkout -- ." -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

# ── Create annotated tag ──────────────────────────────────────────────────────
git -C $src tag -a $tagName -m "Snapshot $Tag"
if ($LASTEXITCODE -ne 0) { Write-Error "git tag failed"; exit 1 }

# ── Report ────────────────────────────────────────────────────────────────────
$sha   = git -C $src rev-parse --short $tagName 2>$null
$count = @(git -C $src ls-tree -r --name-only $tagName 2>$null).Count

Write-Host ""
Write-Host "  Snapshot created" -ForegroundColor Green
Write-Host "  Project  : $Project"
Write-Host "  Tag      : $tagName"
Write-Host "  Commit   : $sha"
Write-Host "  Captured : $count files (full Overleaf_source/ — .tex, .bib, figures, styles)"
Write-Host ""
Write-Host "  List all snapshots : git -C `"$src`" tag -l `"snapshot-*`"" -ForegroundColor DarkGray
Write-Host "  Diff vs now        : git -C `"$src`" diff $tagName HEAD" -ForegroundColor DarkGray
Write-Host "  Restore one file   : git -C `"$src`" checkout $tagName -- main.tex" -ForegroundColor DarkGray
Write-Host "  Restore everything : git -C `"$src`" checkout $tagName" -ForegroundColor DarkGray
