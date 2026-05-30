# update.ps1  --  Pull the latest infrastructure from GitHub
#
# Safe to run at any time. Your local config.local.ps1 is gitignored and
# will never be overwritten.
#
# Usage:
#   helpi 26
#   .\scripts\update.ps1
#
. "$PSScriptRoot\config.ps1"

$sep = "  " + ("-" * 65)

Write-Host ""
Write-Host "  AI Research Infrastructure -- Update" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor DarkGray

# ── 1. Check git remote ───────────────────────────────────────────
Write-Host ""
Write-Host "  [1/4] Checking git remote..." -ForegroundColor DarkYellow
$remote = git -C $aiRoot remote get-url origin 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERR | No git remote found. Is this repo cloned from GitHub?" -ForegroundColor Red
    Write-Host "        Run: git remote add origin https://github.com/jepperich69/ai-infrastructure.git" -ForegroundColor DarkGray
    return
}
Write-Host "  OK: remote origin -> $remote" -ForegroundColor Green

# ── 2. Check for local uncommitted changes ────────────────────────
Write-Host ""
Write-Host "  [2/4] Checking for uncommitted changes..." -ForegroundColor DarkYellow
$dirty = git -C $aiRoot status --porcelain 2>&1 | Where-Object { $_ -notmatch '^(\?\?|!! )' }
if ($dirty) {
    Write-Host "  WARN | Uncommitted changes in working tree:" -ForegroundColor Yellow
    $dirty | ForEach-Object { Write-Host "         $_" -ForegroundColor DarkGray }
    Write-Host "  These will be preserved -- git pull only updates tracked files." -ForegroundColor DarkGray
} else {
    Write-Host "  OK: working tree clean" -ForegroundColor Green
}

# ── 3. git pull ───────────────────────────────────────────────────
Write-Host ""
Write-Host "  [3/4] Pulling latest changes from origin/master..." -ForegroundColor DarkYellow
$currentVersion = if (Test-Path "$aiRoot\VERSION") { (Get-Content "$aiRoot\VERSION" -Raw).Trim() } else { "unknown" }

$pullOut = git -C $aiRoot pull origin master 2>&1
$pullCode = $LASTEXITCODE
$pullOut | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

if ($pullCode -ne 0) {
    Write-Host ""
    Write-Host "  ERR | git pull failed (exit $pullCode). Resolve any conflicts above then re-run." -ForegroundColor Red
    Write-Host "        Your config.local.ps1 is gitignored and safe." -ForegroundColor DarkGray
    return
}

$newVersion = if (Test-Path "$aiRoot\VERSION") { (Get-Content "$aiRoot\VERSION" -Raw).Trim() } else { "unknown" }

if ($currentVersion -eq $newVersion) {
    Write-Host "  Already up to date ($newVersion). No changes pulled." -ForegroundColor Green
} else {
    Write-Host "  Updated: $currentVersion -> $newVersion" -ForegroundColor Green
}

# ── 4. Update hook paths in settings.json ────────────────────────
Write-Host ""
Write-Host "  [4/4] Verifying Claude Code hook paths in settings.json..." -ForegroundColor DarkYellow
$settingsPath = Join-Path $claudeDir "settings.json"
if (!(Test-Path $settingsPath)) {
    Write-Host "  SKIP: settings.json not found at $settingsPath" -ForegroundColor DarkGray
} else {
    $sJson = Get-Content $settingsPath -Raw -Encoding UTF8

    $hooksToCheck = @(
        "log_tool_use.ps1",
        "sync_claude_config.ps1",
        "auto_commit_hook.ps1"
    )
    $needsUpdate = $false
    foreach ($hook in $hooksToCheck) {
        # Detect old-style path (AI_auto\hook.ps1 without scripts\)
        if ($sJson -match [regex]::Escape("AI_auto\\$hook") -or
            $sJson -match [regex]::Escape("AI_auto/$hook")) {
            $needsUpdate = $true
            Write-Host "  WARN | Hook '$hook' still points to old location (AI_auto root)." -ForegroundColor Yellow
        }
    }

    if ($needsUpdate) {
        Write-Host "  Updating hook paths to scripts/ location..." -ForegroundColor DarkYellow
        foreach ($hook in $hooksToCheck) {
            $sJson = $sJson -replace [regex]::Escape("AI_auto\\$hook"), "AI_auto\\scripts\\$hook"
            $sJson = $sJson -replace [regex]::Escape("AI_auto/$hook"),  "AI_auto/scripts/$hook"
        }
        [System.IO.File]::WriteAllText($settingsPath, $sJson, [System.Text.Encoding]::UTF8)
        Write-Host "  OK: hook paths updated in settings.json" -ForegroundColor Green
        Write-Host "  Restart Claude Code for hook changes to take effect." -ForegroundColor DarkGray
    } else {
        Write-Host "  OK: hook paths look correct" -ForegroundColor Green
    }
}

# ── Summary ───────────────────────────────────────────────────────
Write-Host ""
Write-Host $sep -ForegroundColor DarkGray
Write-Host "  Update complete." -ForegroundColor Cyan
Write-Host ""
if ($currentVersion -ne $newVersion) {
    Write-Host "  What changed:" -ForegroundColor White
    Write-Host "    helpi 15  -- open infrastructure guide" -ForegroundColor DarkGray
    Write-Host "    CHANGELOG.md at: $aiRoot\CHANGELOG.md" -ForegroundColor DarkGray
}
Write-Host ""
