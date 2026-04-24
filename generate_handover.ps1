# generate_handover.ps1
# Packages the session log + git history into a handover document.
# Writes _handover.html to the project root (nice to read).
# Also prints markdown to stdout (pipe to a file if needed).
#
# The _ai_log.md is the editable source of truth â€” any agent (Claude, GPT, etc.)
# can update it as plain text. The HTML is regenerated from it each run.
#
# Usage:
#   .\generate_handover.ps1 -Project Pub_AssesTiming_Raoul_TBA
#   .\generate_handover.ps1 -Project Pub_AssesTiming_Raoul_TBA > handover.md
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [int]$RecentCommits = 20
)

. "$PSScriptRoot\ai_log_tools.ps1"

. "$PSScriptRoot\config.ps1"
$projectRoot = Resolve-ProjectRoot $Project
$codeDir     = Join-Path $projectRoot "code"
$logPath     = Join-Path $projectRoot "_ai_log.md"
$htmlPath    = Join-Path $projectRoot "_handover.html"
$jsonPath    = Join-Path $projectRoot "_handover.json"
$generated   = Get-Date -Format "yyyy-MM-dd HH:mm"

if (!(Test-Path $projectRoot)) {
    Write-Host "ERR  | Project not found: $projectRoot"
    exit 1
}

# ---------------------------------------------------------------
# Collect data
# ---------------------------------------------------------------
$sessionLogRaw = if (Test-Path $logPath) { Get-Content $logPath -Raw } else { "" }
$sessionLogLines = if ($sessionLogRaw) { $sessionLogRaw -split "`n" } else { @("_No session log found (_ai_log.md missing)._") }
$sessions = Get-AiLogSessions -Path $logPath
$latestSession = Get-AiLogLatestSession -Path $logPath
$latestSummary = if ($latestSession) { Convert-AiLogSessionToSummary -Session $latestSession } else { $null }
$latestValidation = if ($latestSession) { Test-AiLogSessionComplete -Session $latestSession } else { $null }

$codeGitLog = ""
$codeDiffStat = ""
$hasCodeGit = Test-Path (Join-Path $codeDir ".git")
if ($hasCodeGit) {
    $codeGitLog  = (git -C $codeDir log --oneline -$RecentCommits 2>$null) -join "`n"
    $commitCount = [int](git -C $codeDir rev-list HEAD --count 2>$null)
    if ($commitCount -gt 1) {
        $depth = [Math]::Min(5, $commitCount - 1)
        $codeDiffStat = (git -C $codeDir diff "HEAD~$depth..HEAD" --stat 2>$null) -join "`n"
    }
}

$overleafDir    = Join-Path $projectRoot "Overleaf_source"
$overleafGitLog = ""
$hasOverleafGit = Test-Path (Join-Path $overleafDir ".git")
if ($hasOverleafGit) {
    $overleafGitLog = (git -C $overleafDir log --oneline -$RecentCommits 2>$null) -join "`n"
}

# ---------------------------------------------------------------
# Helper: minimal markdown -> HTML for session log
# Handles: ## headings, **bold**, bullet lists, blank lines
# ---------------------------------------------------------------
function ConvertTo-Html-Fragment {
    param([string[]]$mdLines)
    $html   = ""
    $inList = $false
    foreach ($raw in $mdLines) {
        $line = [System.Web.HttpUtility]::HtmlEncode($raw)
        if ($raw -match '^## (.+)') {
            if ($inList) { $html += "</ul>`n"; $inList = $false }
            $html += "<h2>$([System.Web.HttpUtility]::HtmlEncode($Matches[1]))</h2>`n"
        } elseif ($raw -match '^### (.+)') {
            if ($inList) { $html += "</ul>`n"; $inList = $false }
            $html += "<h3>$([System.Web.HttpUtility]::HtmlEncode($Matches[1]))</h3>`n"
        } elseif ($raw -match '^[-*] (.+)') {
            if (!$inList) { $html += "<ul>`n"; $inList = $true }
            $item = [System.Web.HttpUtility]::HtmlEncode($Matches[1])
            $item = $item -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
            $html += "  <li>$item</li>`n"
        } elseif ($raw.Trim() -eq "" -or $raw.Trim() -eq "---") {
            if ($inList) { $html += "</ul>`n"; $inList = $false }
            if ($raw.Trim() -eq "---") { $html += "<hr>`n" }
            else { $html += "<br>`n" }
        } elseif ($raw -match '^<!--') {
            # skip comments
        } elseif ($raw -match '^#\s') {
            # skip top-level title (shown in header already)
        } else {
            if ($inList) { $html += "</ul>`n"; $inList = $false }
            $line = $line -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
            $line = $line -replace '_(.+?)_', '<em>$1</em>'
            $html += "<p>$line</p>`n"
        }
    }
    if ($inList) { $html += "</ul>`n" }
    return $html
}

function Convert-LinesTo-HtmlList {
    param([string[]]$Lines)
    if (!$Lines -or $Lines.Count -eq 0) { return "<p><em>None recorded.</em></p>" }
    $items = $Lines | ForEach-Object {
        "  <li>$([System.Web.HttpUtility]::HtmlEncode($_))</li>"
    }
    return "<ul>`n$($items -join "`n")`n</ul>"
}

Add-Type -AssemblyName System.Web
$sessionHtml = ConvertTo-Html-Fragment -mdLines $sessionLogLines

$latestSessionHtml = if ($latestSummary) {
    $statusText = if ($latestValidation.is_complete) { "Complete" } else { "Incomplete - missing: $($latestValidation.missing -join ', ')" }
    $statusClass = if ($latestValidation.is_complete) { "ok" } else { "warn" }
    $filesHtml = Convert-LinesTo-HtmlList -Lines $latestSummary.files_touched
@"
<div class="latest-session">
  <div class="session-status $statusClass">$statusText</div>
  <h2>Latest Session Snapshot</h2>
  <p><strong>Session:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.title))</p>
  <p><strong>Agent:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.agent))</p>
  <p><strong>Goal:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.goal))</p>
  <p><strong>Outcome:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.outcome))</p>
  <p><strong>Next steps:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.next_steps))</p>
  $(if ($latestSummary.git_ref) { "<p><strong>Git ref:</strong> $([System.Web.HttpUtility]::HtmlEncode($latestSummary.git_ref))</p>" })
  <h3>Files touched</h3>
  $filesHtml
</div>
"@
} else {
    @"
<div class="latest-session">
  <div class="session-status warn">No sessions found</div>
  <h2>Latest Session Snapshot</h2>
  <p><em>No structured session entries were found in <code style="display:inline;padding:2px 4px">_ai_log.md</code>.</em></p>
</div>
"@
}

# ---------------------------------------------------------------
# Build HTML
# ---------------------------------------------------------------
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Handover - $Project</title>
  <style>
    body { font-family: Georgia, serif; max-width: 860px; margin: 40px auto; padding: 0 24px; color: #1a1a1a; background: #fafafa; }
    h1   { font-size: 1.6em; border-bottom: 2px solid #2c5f8a; padding-bottom: 8px; color: #2c5f8a; }
    h2   { font-size: 1.2em; margin-top: 2em; color: #2c5f8a; border-bottom: 1px solid #cde; padding-bottom: 4px; }
    h3   { font-size: 1em; margin-top: 1.4em; color: #444; }
    .meta { color: #666; font-size: 0.85em; margin-bottom: 2em; }
    .section { background: #fff; border: 1px solid #dde; border-radius: 6px; padding: 20px 24px; margin-bottom: 24px; }
    pre, code { font-family: "Consolas", "Courier New", monospace; font-size: 0.82em; background: #f0f4f8; padding: 12px 16px; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; display: block; }
    hr  { border: none; border-top: 1px solid #dde; margin: 1.5em 0; }
    ul  { padding-left: 1.4em; }
    li  { margin: 4px 0; }
    p   { margin: 6px 0; line-height: 1.6; }
    .agent-box { background: #fffbe6; border: 1px solid #f0d060; border-radius: 6px; padding: 16px 20px; margin-bottom: 24px; }
    .agent-box h2 { color: #7a5c00; border-color: #f0d060; }
    .latest-session { background: #eef5fb; border: 1px solid #c7dcef; border-radius: 6px; padding: 18px 20px; margin-bottom: 24px; }
    .latest-session h2 { margin-top: 0; }
    .session-status { display: inline-block; font-size: 0.8em; font-weight: bold; letter-spacing: 0.03em; padding: 4px 10px; border-radius: 12px; margin-bottom: 10px; }
    .session-status.ok { background: #e3f3e8; color: #1d6238; border: 1px solid #8ac5a0; }
    .session-status.warn { background: #fff1d8; color: #7a5c00; border: 1px solid #e0c06a; }
    textarea { width: 100%; height: 320px; font-family: "Consolas", monospace; font-size: 0.8em; padding: 12px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; background: #f9f9f9; }
    .label { font-size: 0.8em; color: #666; margin-bottom: 4px; }
  </style>
</head>
<body>

<h1>Handover Document &mdash; $Project</h1>
<div class="meta">Generated: $generated &nbsp;|&nbsp; Source: <code style="display:inline;padding:2px 6px">_ai_log.md</code> &nbsp;|&nbsp; Sidecar: <code style="display:inline;padding:2px 6px">_handover.json</code></div>

<!-- ============================================================ -->
<!-- AGENT INSTRUCTIONS                                            -->
<!-- ============================================================ -->
<div class="agent-box">
  <h2>For AI Agents (Claude / GPT / other)</h2>
  <p>This document records the research work done on <strong>$Project</strong>.
  The <strong>editable source of truth</strong> is <code style="display:inline;padding:2px 4px">_ai_log.md</code> in the project root.
  The HTML is regenerated from it by running:</p>
  <pre>.\AI_auto\generate_handover.ps1 -Project $Project</pre>
  <p><strong>To add a session entry:</strong> append a new <code style="display:inline;padding:2px 4px">## Session YYYY-MM-DD</code> block
  to the markdown below (in the textarea), following the existing format.
  Hand the updated markdown back to the user to paste into <code style="display:inline;padding:2px 4px">_ai_log.md</code>.</p>
  <p><strong>What this command now compiles:</strong> a latest-session snapshot, validation of the newest log block, rendered session history, copyable markdown source, git history, and a structured <code style="display:inline;padding:2px 4px">_handover.json</code> sidecar for future tooling.</p>
  <p>Session block format:</p>
  <pre>## Session YYYY-MM-DD
**Agent:** [Claude / GPT-4o / etc.]
**Goal:** [what was worked on]
**Files touched:**
- \`code/file.py\` â€” [description of change]
**Outcome:** [what was accomplished]
**Next steps:** [what remains open]
**Git ref:** [short commit hash(es), if applicable]</pre>
</div>

<!-- ============================================================ -->
<!-- LATEST SESSION SNAPSHOT                                       -->
<!-- ============================================================ -->
$latestSessionHtml

<!-- ============================================================ -->
<!-- SESSION LOG                                                   -->
<!-- ============================================================ -->
<div class="section">
  <h2>Session Log</h2>
  $sessionHtml
</div>

<!-- ============================================================ -->
<!-- EDITABLE MARKDOWN SOURCE                                      -->
<!-- ============================================================ -->
<div class="section">
  <h2>Editable Source (_ai_log.md)</h2>
  <div class="label">Copy this, update it with your session entry, and paste back into _ai_log.md</div>
  <textarea id="mdSource" spellcheck="false">$($sessionLogRaw -replace '<','&lt;' -replace '>','&gt;')</textarea>
</div>

<!-- ============================================================ -->
<!-- CODE GIT HISTORY                                              -->
<!-- ============================================================ -->
<div class="section">
  <h2>Code Git History (last $RecentCommits commits)</h2>
$(if ($codeGitLog) { "  <pre>$([System.Web.HttpUtility]::HtmlEncode($codeGitLog))</pre>" } elseif ($hasCodeGit) { "  <p><em>No commits yet.</em></p>" } else { "  <p><em>code/ is not a git repo. Run <code>init_project_git.ps1</code> first.</em></p>" })
$(if ($codeDiffStat) { "  <h3>Files changed (last 5 commits)</h3>`n  <pre>$([System.Web.HttpUtility]::HtmlEncode($codeDiffStat))</pre>" })
</div>

<!-- ============================================================ -->
<!-- OVERLEAF GIT HISTORY                                          -->
<!-- ============================================================ -->
$(if ($hasOverleafGit) { @"
<div class="section">
  <h2>Overleaf Git History (last $RecentCommits commits)</h2>
  <pre>$([System.Web.HttpUtility]::HtmlEncode($overleafGitLog))</pre>
</div>
"@ })

</body>
</html>
"@

# ---------------------------------------------------------------
# Build AGENTS.md (auto-loaded by Codex CLI and other agents)
# ---------------------------------------------------------------
$agentsPath   = Join-Path $projectRoot "AGENTS.md"
$claudeMdPath = Join-Path $projectRoot ".claude\CLAUDE.md"

$paperBlurb = ""
if (Test-Path $claudeMdPath) {
    $claudeMdRaw = Get-Content $claudeMdPath -Raw
    if ($claudeMdRaw -match '(?s)## What this paper is about\s*\n(.*?)(\n## |\z)') {
        $paperBlurb = $Matches[1].Trim()
    }
}

$agentsLines = @()
$agentsLines += "# Project: $Project"
$agentsLines += "<!-- Auto-generated by generate_handover.ps1 on $generated - do not edit manually -->"
$agentsLines += ""
if ($paperBlurb) {
    $agentsLines += "## What this paper is about"
    $agentsLines += $paperBlurb
    $agentsLines += ""
}
if ($latestSummary) {
    $agentsLines += "## Latest session ($($latestSummary.title))"
    $agentsLines += "**Agent:** $($latestSummary.agent)"
    $agentsLines += "**Goal:** $($latestSummary.goal)"
    $agentsLines += "**Outcome:** $($latestSummary.outcome)"
    $agentsLines += "**Next steps:** $($latestSummary.next_steps)"
    if ($latestSummary.git_ref) { $agentsLines += "**Git ref:** $($latestSummary.git_ref)" }
    $agentsLines += ""
}
$agentsLines += "## Full session log"
$agentsLines += ""
$agentsLines += $sessionLogLines
$agentsLines += ""
$agentsLines += "## How to add a session entry"
$agentsLines += "Append a new block to ``_ai_log.md`` in this project root, then run ``helpi 5 $Project`` to regenerate this file."
$agentsLines += '```'
$agentsLines += "## Session YYYY-MM-DD"
$agentsLines += "**Agent:** [Claude / Codex / GPT-4o / etc.]"
$agentsLines += "**Goal:** [what was worked on]"
$agentsLines += "**Files touched:**"
$agentsLines += "- ``path/file`` -- [description]"
$agentsLines += "**Outcome:** [what was accomplished]"
$agentsLines += "**Next steps:** [what remains open]"
$agentsLines += "**Git ref:** [short commit hash, or -]"
$agentsLines += '```'

[System.IO.File]::WriteAllText($agentsPath, ($agentsLines -join "`n"), [System.Text.Encoding]::UTF8)
Write-Host "OK   | AGENTS.md written:        $agentsPath"

# ---------------------------------------------------------------
# Write HTML + JSON sidecar
# ---------------------------------------------------------------
[PSCustomObject]@{
    project = $Project
    generated = $generated
    source = "_ai_log.md"
    latest_session = $latestSummary
    latest_session_complete = if ($latestValidation) { $latestValidation.is_complete } else { $false }
    latest_session_missing = if ($latestValidation) { $latestValidation.missing } else { @() }
    session_count = $sessions.Count
} | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath -Encoding UTF8

[System.IO.File]::WriteAllText($htmlPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "OK   | HTML handover written: $htmlPath"
Write-Host "OK   | JSON handover written: $jsonPath"

# ---------------------------------------------------------------
# Write _handover_JR.md to Overleaf_source/ for collaborators
# ---------------------------------------------------------------
if ((Test-Path $overleafDir) -and $latestSummary) {
    $collabPath = Join-Path $overleafDir "_handover_JR.md"
    $collabLines = @()
    $collabLines += "# Handover — JR — $generated"
    $collabLines += ""
    $collabLines += "## Last session"
    $collabLines += "**Goal:** $($latestSummary.goal)"
    $collabLines += "**Outcome:** $($latestSummary.outcome)"
    if ($latestSummary.files_touched -and $latestSummary.files_touched.Count -gt 0) {
        $collabLines += "**Files touched:**"
        foreach ($f in $latestSummary.files_touched) { $collabLines += "- $f" }
    }
    $collabLines += ""
    $collabLines += "## Next steps"
    $collabLines += $latestSummary.next_steps
    if ($latestSummary.git_ref) {
        $collabLines += ""
        $collabLines += "## Git ref"
        $collabLines += $latestSummary.git_ref
    }
    [System.IO.File]::WriteAllText($collabPath, ($collabLines -join "`n"), [System.Text.Encoding]::UTF8)
    Write-Host "OK   | Collab handover written: $collabPath"
}
if ($latestValidation -and -not $latestValidation.is_complete) {
    Write-Host "WARN | Latest session block is incomplete: $($latestValidation.missing -join ', ')" -ForegroundColor Yellow
}

# ---------------------------------------------------------------
# Also print markdown to stdout
# ---------------------------------------------------------------
$md = @()
$md += "# Handover Document - $Project"
$md += "Generated: $generated"
$md += ""
$md += "## Session Log"
$md += ""
$md += $sessionLogLines
$md += ""
if ($hasCodeGit) {
    $md += "## Code Git History (last $RecentCommits commits)"
    $md += '```'
    $md += $codeGitLog
    $md += '```'
    if ($codeDiffStat) {
        $md += ""
        $md += "## Files Changed (last 5 commits)"
        $md += '```'
        $md += $codeDiffStat
        $md += '```'
    }
    $md += ""
}
if ($hasOverleafGit) {
    $md += "## Overleaf Git History (last $RecentCommits commits)"
    $md += '```'
    $md += $overleafGitLog
    $md += '```'
}
$md | ForEach-Object { Write-Output $_ }
