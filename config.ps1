# config.ps1  --  Machine-specific paths for the AI research infrastructure
#
# HOW TO USE
#   Do NOT run this file directly -- it is dot-sourced by every other script:
#     . "$PSScriptRoot\config.ps1"
#
# TO SET UP ON A NEW MACHINE
#   1. Set $pubRoot to your publications root folder.
#   2. Adjust $miktexBin / $latexdiffScript / $strawberryPerl if MiKTeX or Perl
#      are installed in non-default locations.
#   3. Everything else is derived automatically.
#
# VARIABLES EXPOSED
#   $aiRoot          — AI_auto/ folder (auto-derived, never edit)
#   $pubRoot         — publications root (contains all Pub_* / Pro_* / PhD_* folders)
#   $vscode          — path to the VS Code CLI binary
#   $claudeDir       — path to the Claude config folder (~/.claude)
#   $miktexBin       — MiKTeX binary folder (for latexmk, pdflatex, etc.)
#   $latexdiffScript — latexdiff Perl script (bundled with MiKTeX)
#   $strawberryPerl  — Perl interpreter (for running latexdiff)
#   $gitUser         — git user.name (used by setup.ps1 for new installs)
#   $gitEmail        — git user.email (used by setup.ps1 for new installs)

# ── Auto-derived (do not edit) ─────────────────────────────────────
$aiRoot          = $PSScriptRoot
$claudeProjectKey = ($aiRoot -replace '[^a-zA-Z0-9]', '-')  # Claude's encoded project path key

# ── Edit these for your machine ───────────────────────────────────
$pubRoot   = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$jrRoot    = Split-Path $pubRoot -Parent  # parent of Publikationer (i.e. JR\)

function Resolve-ProjectRoot([string]$proj) {
    $candidate = Join-Path $pubRoot $proj
    if (Test-Path $candidate) { return $candidate }
    $fallback = Join-Path $jrRoot $proj
    if (Test-Path $fallback) { return $fallback }
    return $candidate
}
$gitUser   = "Jeppe Rich"
$gitEmail  = "jeppe.rich@gmail.com"

# ── Usually correct as-is (derived from Windows env vars) ─────────
$vscode          = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
$claudeDir       = "$env:USERPROFILE\.claude"
$miktexBin       = "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64"
$latexdiffScript = "$env:LOCALAPPDATA\Programs\MiKTeX\scripts\latexdiff\latexdiff"
$strawberryPerl  = "C:\Strawberry\perl\bin\perl.exe"

# ── Overleaf tag-to-folder mapping (used by setup_tagged.ps1) ─────
$tagTargets = @{
    "Projects"      = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Projekter DTU"
    "Teaching"      = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Kurser"
    "Presentations" = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Slides"
    "Applications"  = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Ansogninger"
}
