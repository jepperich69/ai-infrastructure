# setup_project.ps1
# Links an Overleaf project to a local publication folder and adds it to projects.json
#
# Usage:
#   .\setup_project.ps1 -FolderName "Pub_ActionSpace_NatComm" -OverleafUrl "https://git.overleaf.com/XXXXXXXXXXXX"
#   .\setup_project.ps1 -FolderName "Pub_ActionSpace_NatComm" -OverleafUrl "https://git.overleaf.com/XXXXXXXXXXXX" -SubFolder "Paper source"

param(
    [Parameter(Mandatory=$true)]
    [string]$FolderName,        # Name of the folder under Publikationer

    [Parameter(Mandatory=$true)]
    [string]$OverleafUrl,       # Git URL from Overleaf (Menu > Sync > Git)

    [string]$SubFolder = "Overleaf_source",  # Subfolder name to clone into (default: Overleaf_source)

    [string]$Branch = "master"  # Branch name (master or main)
)

$pubRoot   = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$jsonPath  = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\projects.json"

$targetDir = Join-Path $pubRoot $FolderName

# --- Validate local folder exists ---
if (!(Test-Path $targetDir)) {
    Write-Host "ERROR: Folder not found: $targetDir" -ForegroundColor Red
    Write-Host "Available folders:" -ForegroundColor Yellow
    Get-ChildItem $pubRoot -Directory | Select-Object -ExpandProperty Name
    exit 1
}

$clonePath = Join-Path $targetDir $SubFolder

# --- Check not already set up ---
if (Test-Path (Join-Path $clonePath ".git")) {
    Write-Host "Already a git repo at: $clonePath" -ForegroundColor Yellow
    Write-Host "Skipping clone. Checking projects.json..." -ForegroundColor Yellow
} else {
    # --- Clone Overleaf repo ---
    Write-Host "Cloning Overleaf repo into: $clonePath" -ForegroundColor Cyan
    git clone $OverleafUrl $clonePath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: git clone failed." -ForegroundColor Red
        exit 1
    }
}

# --- Add to projects.json if not already present ---
$projects = Get-Content $jsonPath | ConvertFrom-Json

$alreadyIn = $projects | Where-Object { $_.path -eq $clonePath }
if ($alreadyIn) {
    Write-Host "Already in projects.json: $FolderName" -ForegroundColor Yellow
} else {
    $newEntry = [PSCustomObject]@{
        name   = $FolderName
        path   = $clonePath
        branch = $Branch
    }
    $projects += $newEntry
    $projects | ConvertTo-Json -Depth 5 | Set-Content $jsonPath
    Write-Host "Added to projects.json: $FolderName" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! $FolderName is now linked to Overleaf." -ForegroundColor Green
Write-Host "  Local path : $clonePath"
Write-Host "  Overleaf   : $OverleafUrl"
Write-Host "  Branch     : $Branch"
