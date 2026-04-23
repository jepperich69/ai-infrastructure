# push_to_github.ps1 — Push project code/ repo to GitHub
#
# If no remote exists, creates the GitHub repo via gh CLI (no browser needed).
# If a remote already exists, just pushes.
#
# Usage:
#   push_to_github.ps1 -Project Pub_XXX
#   push_to_github.ps1 -Project Pub_XXX -RepoName my-custom-name
#   push_to_github.ps1 -Project Pub_XXX -Visibility public

param(
    [string]$Project    = "",
    [string]$RepoName   = "",
    [string]$Visibility = "private"
)

. "$PSScriptRoot\config.ps1"

if (!$Project) { Write-Host "ERR | -Project is required." -ForegroundColor Red; exit 1 }

$root    = Resolve-ProjectRoot $Project
$codeDir = Join-Path $root "code"

if (!(Test-Path $codeDir)) {
    Write-Host "ERR | No code/ directory found at: $codeDir" -ForegroundColor Red
    exit 1
}

$gitDir = git -C $codeDir rev-parse --git-dir 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERR | code/ is not a git repository. Init it first:" -ForegroundColor Red
    Write-Host "      git init `"$codeDir`"" -ForegroundColor DarkGray
    exit 1
}

# Check for existing remote
$remoteUrl = git -C $codeDir remote get-url origin 2>&1
$hasRemote = $LASTEXITCODE -eq 0

if ($hasRemote) {
    Write-Host ""
    Write-Host "  Remote: $remoteUrl" -ForegroundColor DarkGray
    Write-Host "  Pushing to GitHub..." -ForegroundColor Cyan
    git -C $codeDir push origin
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Pushed." -ForegroundColor Green
    } else {
        Write-Host "  Push failed — check the error above." -ForegroundColor Red
        exit 1
    }
} else {
    # Derive repo name from project if not supplied
    if (!$RepoName) {
        $RepoName = ($Project -replace '^(Pub|Pro|PhD)_', '' `
                             -replace '_', '-').ToLower()
        $RepoName = "$RepoName-code"
    }

    Write-Host ""
    Write-Host "  No remote found. Creating GitHub repo: $RepoName ($Visibility)..." -ForegroundColor Cyan

    Push-Location $codeDir
    gh repo create $RepoName --$Visibility --source=. --remote=origin --push
    $ok = $LASTEXITCODE
    Pop-Location

    if ($ok -eq 0) {
        $newUrl = git -C $codeDir remote get-url origin 2>&1
        Write-Host ""
        Write-Host "  Created and pushed to: $newUrl" -ForegroundColor Green
        Write-Host "  Future pushes: helpi 23 $Project" -ForegroundColor DarkGray
    } else {
        Write-Host "  Failed. Is 'gh' authenticated? Run: gh auth login" -ForegroundColor Red
        exit 1
    }
}
