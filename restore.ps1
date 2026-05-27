# restore.ps1  --  Re-initialise the infrastructure on a replacement machine
#
# Use this when your machine is replaced but your files are intact (e.g. OneDrive sync).
# It checks what is missing and fixes what it can automatically.
#
# Usage:
#   helpi 20
#   .\restore.ps1
#
. "$PSScriptRoot\config.ps1"

$sep = "  " + ("-" * 65)
$ok  = "[OK]  "; $fix = "[FIX] "; $err = "[ERR] "; $info = "[..] "

Write-Host ""
Write-Host "  Restore: AI Research Infrastructure" -ForegroundColor Cyan
Write-Host $sep -ForegroundColor DarkGray

# ── 1. Claude Code CLI ────────────────────────────────────────────
Write-Host ""
Write-Host "  1. Claude Code CLI" -ForegroundColor DarkYellow
$claudeOk = $false
try {
    $v = & claude --version 2>&1
    Write-Host "  $ok claude $v" -ForegroundColor Green
    $claudeOk = $true
} catch {
    Write-Host "  $err Not found. Install from: https://claude.ai/download" -ForegroundColor Red
    Write-Host "       Then run: claude login" -ForegroundColor DarkGray
}

# ── 2. Git ────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  2. Git" -ForegroundColor DarkYellow
try {
    $v = (git --version 2>&1) -replace "git version ", ""
    Write-Host "  $ok git $v" -ForegroundColor Green
} catch {
    Write-Host "  $err Not found. Install from: https://git-scm.com/download/win" -ForegroundColor Red
}

# ── 3. MiKTeX (LaTeX) ─────────────────────────────────────────────
Write-Host ""
Write-Host "  3. MiKTeX (LaTeX)" -ForegroundColor DarkYellow
if (Test-Path "$miktexBin\latexmk.exe") {
    Write-Host "  $ok latexmk found at $miktexBin" -ForegroundColor Green
} else {
    Write-Host "  $err Not found at: $miktexBin" -ForegroundColor Red
    Write-Host "       Install from: https://miktex.org/download" -ForegroundColor DarkGray
    Write-Host "       Then update config.ps1 if installed in a non-default location." -ForegroundColor DarkGray
}

# ── 4. VS Code ────────────────────────────────────────────────────
Write-Host ""
Write-Host "  4. VS Code" -ForegroundColor DarkYellow
if (Test-Path $vscode) {
    Write-Host "  $ok VS Code CLI found" -ForegroundColor Green
} else {
    Write-Host "  $err Not found at: $vscode" -ForegroundColor Red
    Write-Host "       Install from: https://code.visualstudio.com/" -ForegroundColor DarkGray
}

# ── 5. PowerShell profile (helpi function) ────────────────────────
Write-Host ""
Write-Host "  5. PowerShell profile (helpi)" -ForegroundColor DarkYellow
$profilePath = $PROFILE.CurrentUserAllHosts
$helpiCall   = "function helpi { & `"$aiRoot\helpi.ps1`" @args }"
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($profileContent -match 'helpi') {
        Write-Host "  $ok helpi already wired in profile: $profilePath" -ForegroundColor Green
    } else {
        Add-Content $profilePath "`n# AI infrastructure`n$helpiCall"
        Write-Host "  $fix Added helpi to profile: $profilePath" -ForegroundColor Yellow
        Write-Host "       Restart your terminal or run: . `$PROFILE" -ForegroundColor DarkGray
    }
} else {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
    Add-Content $profilePath "# AI infrastructure`n$helpiCall"
    Write-Host "  $fix Created profile and added helpi: $profilePath" -ForegroundColor Yellow
    Write-Host "       Restart your terminal or run: . `$PROFILE" -ForegroundColor DarkGray
}

# ── 6. Claude config folder (~/.claude) ───────────────────────────
Write-Host ""
Write-Host "  6. Claude config folder (~/.claude)" -ForegroundColor DarkYellow
$backupDir = Join-Path $aiRoot "_claude_backup"
$claudeOk  = (Test-Path "$claudeDir\CLAUDE.md") -and (Test-Path "$claudeDir\commands\close.md")
if ($claudeOk) {
    Write-Host "  $ok ~/.claude already present (CLAUDE.md + commands/)" -ForegroundColor Green
} elseif (Test-Path $backupDir) {
    Write-Host "  $fix Restoring ~/.claude from _claude_backup/ ..." -ForegroundColor Yellow
    & "$aiRoot\sync_claude_config.ps1" -Restore
} else {
    Write-Host "  $err ~/.claude missing and no _claude_backup/ found." -ForegroundColor Red
    Write-Host "       Cannot auto-restore. Copy ~/.claude from another machine or cloud backup." -ForegroundColor DarkGray
}

# ── 7. Scheduled task (auto-sync every 4h) ───────────────────────
Write-Host ""
Write-Host "  7. Scheduled task (auto-sync)" -ForegroundColor DarkYellow
$task = Get-ScheduledTask -TaskName "AI_AutoSync" -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "  $ok Scheduled task 'AI_AutoSync' exists (state: $($task.State))" -ForegroundColor Green
} else {
    Write-Host "  $fix Registering scheduled task 'AI_AutoSync' (every 4h)..." -ForegroundColor Yellow
    $action  = New-ScheduledTaskAction -Execute "powershell.exe" `
                 -Argument "-NoProfile -WindowStyle Hidden -File `"$aiRoot\sync_all.ps1`""
    $trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Hours 4) -Once `
                 -At (Get-Date).Date
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
                  -StartWhenAvailable
    Register-ScheduledTask -TaskName "AI_AutoSync" -Action $action -Trigger $trigger `
      -Settings $settings -RunLevel Highest -Force | Out-Null
    Write-Host "  $ok Task registered." -ForegroundColor Green
}

# ── 8. projects.json ──────────────────────────────────────────────
Write-Host ""
Write-Host "  8. projects.json" -ForegroundColor DarkYellow
$jsonPath = Join-Path $aiRoot "projects.json"
if (Test-Path $jsonPath) {
    $count = (Get-Content $jsonPath | ConvertFrom-Json).Count
    Write-Host "  $ok projects.json found ($count projects registered)" -ForegroundColor Green
} else {
    Write-Host "  $err projects.json missing at: $jsonPath" -ForegroundColor Red
    Write-Host "       Restore from backup or re-register projects with helpi 1." -ForegroundColor DarkGray
}

# ── Summary ───────────────────────────────────────────────────────
Write-Host ""
Write-Host $sep -ForegroundColor DarkGray
Write-Host "  Done. Fix any [ERR] items above, then restart your terminal." -ForegroundColor Cyan
Write-Host "  Run 'helpi' to confirm everything is working." -ForegroundColor DarkGray
Write-Host ""
