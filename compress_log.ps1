# compress_log.ps1 — Tiered compression for _ai_log.md
#
# Keeps the last $ActiveCount sessions verbatim (default: 4).
# Compresses older sessions into one-liners under ## Compressed sessions.
# Archives one-liners to _ai_log_archive.md once they exceed $MaxCompressed (default: 16).
#
# Usage:
#   compress_log.ps1                     # operates on _ai_log.md in current directory
#   compress_log.ps1 -Project Pub_XXX    # resolves project root via config.ps1
#   compress_log.ps1 -Project AI_auto

param(
    [string]$Project    = "",
    [int]$ActiveCount   = 4,
    [int]$MaxCompressed = 16
)

. "$PSScriptRoot\config.ps1"

# --- Resolve log path ---
if ($Project) {
    $root    = Resolve-ProjectRoot $Project
    $logPath = Join-Path $root "_ai_log.md"
} else {
    $logPath = Join-Path (Get-Location) "_ai_log.md"
}

if (!(Test-Path $logPath)) {
    Write-Host "  compress_log: no _ai_log.md at $logPath" -ForegroundColor DarkGray
    exit 0
}

$raw   = Get-Content $logPath -Raw -Encoding UTF8
$lines = $raw -split "`r?`n"

# --- Extract title ---
$title = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1)
if (!$title) { $title = "# AI Session Log" }

# --- Extract existing compressed one-liners (from a prior run) ---
$existingCompressed = [System.Collections.Generic.List[string]]::new()
$inCompressed = $false
foreach ($line in $lines) {
    if ($line -match '^## Compressed sessions') { $inCompressed = $true; continue }
    if ($inCompressed) {
        if ($line -match '^---') { break }
        if ($line -match '^- \*\*') { [void]$existingCompressed.Add($line) }
    }
}

# --- Find all ## Session blocks ---
$sessionRegex   = [regex]'(?m)^## Session '
$sessionMatches = $sessionRegex.Matches($raw)

if ($sessionMatches.Count -le $ActiveCount) {
    Write-Host "  compress_log: $($sessionMatches.Count) session(s) — at or below threshold ($ActiveCount), nothing to do." -ForegroundColor DarkGray
    exit 0
}

# Extract each block as trimmed text (trailing --- and whitespace stripped)
$sessionBlocks = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $sessionMatches.Count; $i++) {
    $start = $sessionMatches[$i].Index
    $end   = if ($i + 1 -lt $sessionMatches.Count) { $sessionMatches[$i + 1].Index } else { $raw.Length }
    $block = $raw.Substring($start, $end - $start).TrimEnd(" `r`n-")
    [void]$sessionBlocks.Add($block)
}

# --- Summarise a session block into one line ---
function Get-OneLiner([string]$block) {
    $date    = if ($block -match '## Session ([^\r\n]+)')         { $Matches[1].Trim() } else { "?" }
    $agent   = if ($block -match '\*\*Agent:\*\*\s*([^\r\n]+)')   { $Matches[1].Trim() } else { "?" }
    $goal    = if ($block -match '\*\*Goal:\*\*\s*([^\r\n]+)')    { $Matches[1].Trim() } else { "—" }
    $outcome = if ($block -match '\*\*Outcome:\*\*\s*([^\r\n]+)') { $Matches[1].Trim() } else { "—" }

    $agentShort = $agent -replace 'Claude (Sonnet|Opus|Haiku) \d+\.\d+', 'Claude' `
                         -replace 'GPT-\d+(\.\d+)? Codex', 'Codex'

    if ($goal.Length    -gt 70) { $goal    = $goal.Substring(0, 67)    + "..." }
    if ($outcome.Length -gt 90) { $outcome = $outcome.Substring(0, 87) + "..." }

    return "- **$date** ($agentShort): $goal → $outcome"
}

# Sessions to compress: all but the last $ActiveCount
$compressCount  = $sessionBlocks.Count - $ActiveCount
$toCompressIdx  = 0..($compressCount - 1)
$toKeepIdx      = $compressCount..($sessionBlocks.Count - 1)

$newOneLiners  = $toCompressIdx | ForEach-Object { Get-OneLiner $sessionBlocks[$_] }
$allCompressed = [System.Collections.Generic.List[string]]::new()
foreach ($l in $existingCompressed) { [void]$allCompressed.Add($l) }
foreach ($l in $newOneLiners)       { [void]$allCompressed.Add($l) }

# --- Archive overflow ---
$archivePath = Join-Path (Split-Path $logPath) "_ai_log_archive.md"
if ($allCompressed.Count -gt $MaxCompressed) {
    $overflowCount  = $allCompressed.Count - $MaxCompressed
    $toArchive      = $allCompressed.GetRange(0, $overflowCount)
    $allCompressed.RemoveRange(0, $overflowCount)

    $archiveHeader = "`n`n---`n`n## Archived $(Get-Date -Format 'yyyy-MM-dd') ($overflowCount entr$(if ($overflowCount -eq 1) {'y'} else {'ies'}))`n`n"
    $archiveBody   = $toArchive -join "`n"
    if (!(Test-Path $archivePath)) {
        $logName = Split-Path (Split-Path $logPath) -Leaf
        Set-Content $archivePath "# AI Session Log Archive — $logName$archiveHeader$archiveBody" -Encoding UTF8
    } else {
        Add-Content $archivePath "$archiveHeader$archiveBody" -Encoding UTF8
    }
    Write-Host "  compress_log: archived $overflowCount oldest one-liner(s) -> _ai_log_archive.md" -ForegroundColor DarkYellow
}

# --- Rebuild _ai_log.md ---
$sb = [System.Text.StringBuilder]::new()

[void]$sb.Append("$title`n`n---`n`n")

if ($allCompressed.Count -gt 0) {
    [void]$sb.Append("## Compressed sessions`n`n")
    foreach ($l in $allCompressed) { [void]$sb.Append("$l`n") }
    [void]$sb.Append("`n---`n`n")
}

$toKeep = $toKeepIdx | ForEach-Object { $sessionBlocks[$_] }
for ($i = 0; $i -lt $toKeep.Count; $i++) {
    [void]$sb.Append("$($toKeep[$i])`n`n---")
    if ($i -lt $toKeep.Count - 1) { [void]$sb.Append("`n`n") }
}

$newContent = $sb.ToString().TrimEnd("`r`n -")
Set-Content $logPath $newContent -Encoding UTF8

Write-Host "  compress_log: $compressCount session(s) compressed. Active: $ActiveCount. One-liners in log: $($allCompressed.Count)." -ForegroundColor Green
