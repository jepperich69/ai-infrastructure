# sync_claude_config.ps1  --  Backup or restore ~/.claude to/from _claude_backup/
#
# -Backup   copy ~/.claude -> _claude_backup/   (called by Stop hook every session)
# -Restore  copy _claude_backup/ -> ~/.claude/  (called by restore.ps1 / helpi 20)
#
# Backs up: CLAUDE.md, settings.json, commands/, skills/, projects/*.md
# Excludes: .credentials.json, history.jsonl, cache/, sessions/ (machine-local state)

param(
    [switch]$Backup,
    [switch]$Restore
)

$claudeDir = "$env:USERPROFILE\.claude"
$backupDir = Join-Path $PSScriptRoot "_claude_backup"

function Sync-Dir($src, $dst) {
    if (!(Test-Path $dst)) { New-Item -ItemType Directory $dst -Force | Out-Null }
    robocopy $src $dst /E /NJH /NJS /NFL /NDL /NC /NS /NP 2>$null | Out-Null
}

function Sync-DirMdOnly($src, $dst) {
    if (!(Test-Path $dst)) { New-Item -ItemType Directory $dst -Force | Out-Null }
    robocopy $src $dst "*.md" /S /NJH /NJS /NFL /NDL /NC /NS /NP 2>$null | Out-Null
}

if ($Backup) {
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory $backupDir -Force | Out-Null }

    foreach ($f in @("CLAUDE.md", "settings.json")) {
        $src = Join-Path $claudeDir $f
        if (Test-Path $src) { Copy-Item $src (Join-Path $backupDir $f) -Force }
    }

    foreach ($d in @("commands", "skills")) {
        $src = Join-Path $claudeDir $d
        if (Test-Path $src) { Sync-Dir $src (Join-Path $backupDir $d) }
    }

    # projects/ -- .md only; skips large cache/session blobs
    $src = Join-Path $claudeDir "projects"
    if (Test-Path $src) { Sync-DirMdOnly $src (Join-Path $backupDir "projects") }

    Write-Host "claude config backed up -> _claude_backup/" -ForegroundColor DarkGray
}
elseif ($Restore) {
    if (!(Test-Path $backupDir)) {
        Write-Host "  [ERR] _claude_backup/ not found -- nothing to restore." -ForegroundColor Red
        exit 1
    }

    if (!(Test-Path $claudeDir)) { New-Item -ItemType Directory $claudeDir -Force | Out-Null }

    foreach ($f in @("CLAUDE.md", "settings.json")) {
        $src = Join-Path $backupDir $f
        if (Test-Path $src) { Copy-Item $src (Join-Path $claudeDir $f) -Force }
    }

    foreach ($d in @("commands", "skills", "projects")) {
        $src = Join-Path $backupDir $d
        if (Test-Path $src) { Sync-Dir $src (Join-Path $claudeDir $d) }
    }

    Write-Host "  [OK]  ~/.claude restored from _claude_backup/" -ForegroundColor Green
}
else {
    Write-Host "Usage: sync_claude_config.ps1 -Backup | -Restore" -ForegroundColor Yellow
}
