# new_generic_project.ps1
# Lightweight init for a non-paper project folder anywhere under JR.
# Adds the same logging/handover/compression scaffolding as a paper project
# (helpi 1), without the Overleaf/LaTeX/code/Literature structure.
#
# Usage:
#   new_generic_project.ps1                       # initializes the current directory
#   new_generic_project.ps1 -Project MyFolder      # creates/initializes JR\MyFolder
#   new_generic_project.ps1 -Project "Interne projekter\Foo"

param(
    [string]$Project = ""
)

. "$PSScriptRoot\config.ps1"

# Generic projects live directly under JR, not under Publikationer -- so a
# bare name resolves there, not via Resolve-ProjectRoot (which is biased
# toward pubRoot and would misplace a not-yet-existing folder).
$projectRoot = if (!$Project) {
    (Get-Location).Path
} elseif ([System.IO.Path]::IsPathRooted($Project)) {
    $Project
} else {
    Join-Path $jrRoot $Project
}

if (!(Test-Path $projectRoot)) {
    New-Item -ItemType Directory -Path $projectRoot -Force | Out-Null
    Write-Host "OK   | Created folder: $projectRoot"
}

$projectName = Split-Path $projectRoot -Leaf

if (Test-Path (Join-Path $projectRoot "_ai_log.md")) {
    Write-Host "ERR  | Already initialized -- _ai_log.md exists at $projectRoot"
    exit 1
}

Write-Host "Initializing generic project: $projectName"
Write-Host "  $projectRoot"

# -- Literature source log ---------------------------------------------
$literatureDir = Join-Path $projectRoot "Literature"
New-Item -ItemType Directory -Path $literatureDir -Force | Out-Null
$retrievedSources = @"
# Retrieved sources (AI-fetched literature)

Index of full-text sources pulled from the web while answering questions about
the project. Each entry records the citation, the local file, where it is used,
and the specific fact it supports, so claims that lean on the literature can be
re-checked without re-downloading.

---

<!--
## Author(s) (Year), *Title*
- **File:** `Local_file_name.pdf`
- **Bib key:** `bibkey`
- **Source:** official full text, https://...
- **Retrieved:** YYYY-MM-DD
- **Used in project:** path/to/file -- section/equation/paragraph
- **What it supports / verified facts:**
  - Fact 1, with page/section/anchor when available.
  - Fact 2, with page/section/anchor when available.
-->
"@
Set-Content -Path (Join-Path $literatureDir "_retrieved_sources.md") -Value $retrievedSources
Write-Host "OK   | Literature/_retrieved_sources.md created"

# -- Session log --------------------------------------------------------
$logContent = @"
# AI Session Log - $projectName

<!-- Claude updates this file at the start and end of every working session. -->
<!-- Format: one ## Session block per date. -->

"@
Set-Content -Path (Join-Path $projectRoot "_ai_log.md") -Value $logContent
Write-Host "OK   | _ai_log.md created"

# -- Proxy-sandbox: per-project Claude permissions -----------------------
$projClaudeDir = Join-Path $projectRoot ".claude"
New-Item -ItemType Directory -Path $projClaudeDir -Force | Out-Null
$sandboxSettings = @"
{
  "permissions": {
    "deny": [
      "Read(C:/Users/rich/OneDrive*/JR/AI_auto/**)",
      "Read(C:/Users/rich/AppData/**)",
      "Read(C:/Users/rich/.claude/**)"
    ]
  }
}
"@
Set-Content -Path (Join-Path $projClaudeDir "settings.json") -Value $sandboxSettings
Write-Host "OK   | .claude/settings.json created (proxy-sandbox active)"

# -- Per-project CLAUDE.md (generic, non-paper) ---------------------------
$claudeMd = @"
# Project: $projectName

<!-- This file is read by Claude Code at session start. Keep it current but brief.
     Session-by-session changes go in _ai_log.md -- not here. -->

## What this project is about
<!-- 2-4 sentences: what is this folder for, what are you trying to accomplish. -->


## Key files
- **Retrieved web sources:** ``Literature/_retrieved_sources.md``

## Standing constraints
<!-- Conventions or constraints that are always true for this project. -->
- [add as they emerge]

## What NOT to touch
<!-- Files or folders that are frozen or off-limits unless explicitly instructed. -->
- [add as they emerge]
"@
Set-Content -Path (Join-Path $projClaudeDir "CLAUDE.md") -Value $claudeMd
Write-Host "OK   | .claude/CLAUDE.md created (fill in project details)"

Write-Host ""
Write-Host "Done. Project ready at:"
Write-Host "  $projectRoot"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Fill in .claude\CLAUDE.md with what this project is about"
Write-Host "  - cd into the folder and start a Claude Code session"
Write-Host "  - /work, /close, helpi 7 (log+handover), helpi 13/14 (dashboard/network),"
Write-Host "    and helpi 22 (compress log) all work the same as for paper projects"
