# config.ps1  --  Shared paths for the AI research infrastructure
#
# HOW TO USE
#   Do NOT run this file directly -- dot-sourced by every other script:
#     . "$PSScriptRoot\config.ps1"
#
# USER SETUP
#   Copy config.local.example.ps1 to config.local.ps1 and fill in your paths.
#   config.local.ps1 is gitignored -- it never conflicts on git pull.
#   Run 'helpi 21' to have the wizard create it for you.
#
# VARIABLES EXPOSED
#   $aiRoot          -- AI_auto/ folder (auto-derived, never edit)
#   $pubRoot         -- publications root (contains all Pub_* / Pro_* / PhD_* folders)
#   $vscode          -- path to the VS Code CLI binary
#   $claudeDir       -- path to the Claude config folder (~/.claude)
#   $miktexBin       -- MiKTeX binary folder (for latexmk, pdflatex, etc.)
#   $latexdiffScript -- latexdiff Perl script (bundled with MiKTeX)
#   $strawberryPerl  -- Perl interpreter (for running latexdiff)
#   $gitUser         -- git user.name
#   $gitEmail        -- git user.email

# ── Auto-derived (do not edit) ───────────────────────────────────────
# $aiRoot is the AI_auto/ folder (parent of scripts/)
$aiRoot           = Split-Path $PSScriptRoot -Parent
$claudeProjectKey = ($aiRoot -replace '[^a-zA-Z0-9]', '-')

# ── Defaults (correct for most Windows installs) ─────────────────────
$pubRoot         = ""          # set in config.local.ps1
$gitUser         = ""          # set in config.local.ps1
$gitEmail        = ""          # set in config.local.ps1
$vscode          = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
$claudeDir       = "$env:USERPROFILE\.claude"
$miktexBin       = "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64"
$latexdiffScript = "$env:LOCALAPPDATA\Programs\MiKTeX\scripts\latexdiff\latexdiff"
$strawberryPerl  = "C:\Strawberry\perl\bin\perl.exe"

# ── Overleaf tag-to-folder mapping (used by setup_tagged.ps1) ────────
# Override in config.local.ps1 if your folder layout differs.
$tagTargets = @{
    "Projects"      = ""
    "Teaching"      = ""
    "Presentations" = ""
    "Applications"  = ""
}

# ── Helper: resolve a short project name to its full path ────────────
function Resolve-ProjectRoot([string]$proj) {
    if (!$pubRoot) { return $proj }
    $jrRoot    = Split-Path $pubRoot -Parent
    $candidate = Join-Path $pubRoot $proj
    if (Test-Path $candidate) { return $candidate }
    $fallback  = Join-Path $jrRoot $proj
    if (Test-Path $fallback)  { return $fallback }
    return $candidate
}

# ── Load machine-specific overrides (gitignored) ─────────────────────
$_localConfig = Join-Path $PSScriptRoot "config.local.ps1"
if (Test-Path $_localConfig) {
    . $_localConfig
    # Re-derive jrRoot after pubRoot may have been set
} else {
    Write-Warning "config.local.ps1 not found. Run 'helpi 21' to set up your local configuration."
}
