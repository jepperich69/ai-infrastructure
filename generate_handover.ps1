# generate_handover.ps1
# Packages the session log + git history into a handover document.
# Writes _handover.html to the project root (nice to read).
# Also prints markdown to stdout (pipe to a file if needed).
#
# The _ai_log.md is the editable source of truth — any agent (Claude, GPT, etc.)
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

$pubRoot     = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$projectRoot = Join-Path $pubRoot $Project
$codeDir     = Join-Path $projectRoot "code"
$logPath     = Join-Path $projectRoot "_ai_log.md"
$htmlPath    = Join-Path $projectRoot "_handover.html"
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

Add-Type -AssemblyName System.Web
$sessionHtml = ConvertTo-Html-Fragment -mdLines $sessionLogLines

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
    textarea { width: 100%; height: 320px; font-family: "Consolas", monospace; font-size: 0.8em; padding: 12px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; background: #f9f9f9; }
    .label { font-size: 0.8em; color: #666; margin-bottom: 4px; }
  </style>
</head>
<body>

<h1>Handover Document &mdash; $Project</h1>
<div class="meta">Generated: $generated &nbsp;|&nbsp; Source: <code style="display:inline;padding:2px 6px">_ai_log.md</code></div>

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
  <p>Session block format:</p>
  <pre>## Session YYYY-MM-DD
**Agent:** [Claude / GPT-4o / etc.]
**Goal:** [what was worked on]
**Files touched:**
- \`code/file.py\` — [description of change]
**Outcome:** [what was accomplished]
**Next steps:** [what remains open]
**Git ref:** [short commit hash(es), if applicable]</pre>
</div>

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
# Write HTML
# ---------------------------------------------------------------
[System.IO.File]::WriteAllText($htmlPath, $html, [System.Text.Encoding]::UTF8)
Write-Host "OK   | HTML handover written: $htmlPath"

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
