# config.local.example.ps1  --  Local machine configuration template
#
# INSTRUCTIONS
#   1. Copy this file to config.local.ps1 (same folder).
#   2. Fill in the values for your machine.
#   3. config.local.ps1 is gitignored -- it will never conflict on 'git pull'.
#
# You can also run 'helpi 21' and the setup wizard will create this file for you.

# ── Required ──────────────────────────────────────────────────────────
# Path to the folder that contains all your Pub_* / Pro_* / PhD_* project folders.
# Example: "C:\Users\YourName\OneDrive\Research\Publikationer"
$pubRoot  = "C:\Users\YourName\path\to\Publikationer"

# Git identity
$gitUser  = "Your Name"
$gitEmail = "you@example.com"

# ── Optional: override tool paths if not in default locations ─────────
# $vscode          = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
# $miktexBin       = "$env:LOCALAPPDATA\Programs\MiKTeX\miktex\bin\x64"
# $latexdiffScript = "$env:LOCALAPPDATA\Programs\MiKTeX\scripts\latexdiff\latexdiff"
# $strawberryPerl  = "C:\Strawberry\perl\bin\perl.exe"

# ── Optional: Overleaf tag-to-folder mapping (used by setup_tagged.ps1) ──
# Only needed if you use tagged Overleaf projects beyond Publikationer.
# $tagTargets = @{
#     "Projects"      = "C:\Users\YourName\path\to\Projects"
#     "Teaching"      = "C:\Users\YourName\path\to\Courses"
#     "Presentations" = "C:\Users\YourName\path\to\Slides"
#     "Applications"  = "C:\Users\YourName\path\to\Applications"
# }
