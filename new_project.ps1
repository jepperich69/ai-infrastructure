# new_project.ps1
# Scaffold a complete new paper project folder structure.
#
# Usage:
#   .\new_project.ps1 -Project Pub_NewPaper_TBA
#   .\new_project.ps1 -Project Pub_NewPaper_TBA -GitUrl https://git.overleaf.com/abc123
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [string]$GitUrl = ""   # Overleaf git URL — clone into Overleaf_source/ if provided
)

$pubRoot     = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$aiRoot      = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto"
$projectRoot = Join-Path $pubRoot $Project

if (Test-Path $projectRoot) {
    Write-Host "ERR  | Project folder already exists: $projectRoot"
    exit 1
}

Write-Host "Creating project: $Project"

# ── Folder structure ──────────────────────────────────────────────
foreach ($sub in @("code", "code\data", "Literature")) {
    New-Item -ItemType Directory -Path (Join-Path $projectRoot $sub) -Force | Out-Null
}
Write-Host "OK   | Folders created (code/, code/data/, Literature/)"

# ── Overleaf_source ───────────────────────────────────────────────
$overleafDir = Join-Path $projectRoot "Overleaf_source"
if ($GitUrl) {
    Write-Host "Cloning Overleaf repo..."
    git clone --quiet $GitUrl $overleafDir 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "OK   | Overleaf_source cloned from $GitUrl"

        # Register in projects.json
        $jsonPath = "$aiRoot\projects.json"
        $projects = Get-Content $jsonPath | ConvertFrom-Json
        $branch   = "master"
        $head     = Join-Path $overleafDir ".git\HEAD"
        if (Test-Path $head) {
            $hc = Get-Content $head
            if ($hc -match "refs/heads/(.+)") { $branch = $Matches[1] }
        }
        $projects += [PSCustomObject]@{ name = $Project; path = $overleafDir; branch = $branch }
        $projects | ConvertTo-Json -Depth 5 | Set-Content $jsonPath
        Write-Host "OK   | Registered in projects.json (branch: $branch)"
    } else {
        Write-Host "ERR  | Clone failed — creating empty Overleaf_source/ instead"
        New-Item -ItemType Directory -Path $overleafDir -Force | Out-Null
    }
} else {
    New-Item -ItemType Directory -Path $overleafDir -Force | Out-Null
    Set-Content -Path (Join-Path $overleafDir "README.md") -Value "# $Project`n`nLink Overleaf git URL here and run sync_all.ps1."
    Write-Host "OK   | Overleaf_source/ created (placeholder — add git URL later)"
}

# ── Git in code/ ──────────────────────────────────────────────────
$codeDir = Join-Path $projectRoot "code"
$gitignore = @"
__pycache__/
*.pyc
*.pyo
*.pyd
.ipynb_checkpoints/
.env
*.egg-info/
dist/
build/
"@
Set-Content -Path (Join-Path $codeDir ".gitignore") -Value $gitignore
git -C $codeDir init --quiet
git -C $codeDir add -A
git -C $codeDir commit --quiet -m "init: $Project"
Write-Host "OK   | Git initialised in code/"

# ── Session log ───────────────────────────────────────────────────
$logContent = @"
# AI Session Log - $Project

<!-- Claude updates this file at the start and end of every working session. -->
<!-- Format: one ## Session block per date. -->

"@
Set-Content -Path (Join-Path $projectRoot "_ai_log.md") -Value $logContent
Write-Host "OK   | _ai_log.md created"

# ── Proxy-sandbox: per-project Claude permissions ─────────────────
$claudeDir = Join-Path $projectRoot ".claude"
New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
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
Set-Content -Path (Join-Path $claudeDir "settings.json") -Value $sandboxSettings
Write-Host "OK   | .claude/settings.json created (proxy-sandbox active)"

# ── Per-project CLAUDE.md (session briefing) ──────────────────────
$claudeMd = @"
# Project: $Project

<!-- This file is read by Claude Code at session start. Keep it current but brief.
     Session-by-session changes go in _ai_log.md — not here.
     Update this file when: co-authors change, venue changes, a section is frozen, notation is locked. -->

## What this paper is about
<!-- 3-5 sentences: problem, method, main result. Enough to orient a smart colleague cold. -->


## People
- **PI:** Jeppe Rich
- **Co-authors:** [Name, role]
- **Overleaf URL:** [https://git.overleaf.com/...]

## Venue
- **Target journal:** TBA
- **Current phase:** Writing
- **Submission deadline:** none set

## Key files
- **Main manuscript:** ``Overleaf_source/main.tex``
- **Main code:** ``code/[primary script]``

## Standing constraints
<!-- Notation conventions, frozen sections, reviewer mandates — things always true for this paper. -->
- [add as they emerge]

## What NOT to touch
<!-- Files or sections that are frozen or off-limits unless explicitly instructed. -->
- [add as they emerge]
"@
Set-Content -Path (Join-Path $claudeDir "CLAUDE.md") -Value $claudeMd
Write-Host "OK   | .claude/CLAUDE.md created (fill in project details)"

Write-Host ""
Write-Host "Done. Project ready at:"
Write-Host "  $projectRoot"
Write-Host ""
Write-Host "Next steps:"
if (!$GitUrl) {
    Write-Host "  - Add Overleaf git URL to Overleaf_source\README.md and run sync_all.ps1"
}
Write-Host "  - Fill in .claude\CLAUDE.md with project details (co-authors, venue, key files)"
Write-Host "  - helpi 4 $Project   (open in VS Code)"
Write-Host "  - helpi 3 $Project   (compile LaTeX)"
