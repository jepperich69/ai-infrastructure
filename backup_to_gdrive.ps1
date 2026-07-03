$DestRoot = "G:\My Drive\JR_Backup"
$SrcRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR"

Write-Host "Starting backup to Google Drive ($DestRoot)..." -ForegroundColor Cyan

# Ensure destination root exists
if (-not (Test-Path $DestRoot)) {
    New-Item -ItemType Directory -Path $DestRoot | Out-Null
}

$RobocopyArgs = @("/MIR", "/FFT", "/Z", "/W:1", "/R:1", "/MT:8", "/NP", "/NDL")

# 1. Backup NoteTaker
Write-Host "`n--- Backing up NoteTaker ---" -ForegroundColor Yellow
$SrcNoteTaker = Join-Path $SrcRoot "NoteTaker"
$DestNoteTaker = Join-Path $DestRoot "NoteTaker"
$argsNoteTaker = @($SrcNoteTaker, $DestNoteTaker) + $RobocopyArgs
& robocopy $argsNoteTaker | Out-Null

# 2. Backup AI_auto
Write-Host "`n--- Backing up AI_auto ---" -ForegroundColor Yellow
$SrcAIAuto = Join-Path $SrcRoot "AI_auto"
$DestAIAuto = Join-Path $DestRoot "AI_auto"
$argsAIAuto = @($SrcAIAuto, $DestAIAuto) + $RobocopyArgs
& robocopy $argsAIAuto | Out-Null

# 3. Backup Publikationer/Pub_*
Write-Host "`n--- Backing up Pub_ projects to 'publications' ---" -ForegroundColor Yellow
$SrcPubs = Join-Path $SrcRoot "Publikationer"
$DestPubs = Join-Path $DestRoot "publications"

if (-not (Test-Path $DestPubs)) {
    New-Item -ItemType Directory -Path $DestPubs | Out-Null
}

$PubFolders = Get-ChildItem -Path $SrcPubs -Directory -Filter "Pub_*"
foreach ($folder in $PubFolders) {
    Write-Host "Backing up $($folder.Name)..." -ForegroundColor Gray
    $DestFolder = Join-Path $DestPubs $folder.Name
    $argsPub = @($folder.FullName, $DestFolder) + $RobocopyArgs
    & robocopy $argsPub | Out-Null
}

Write-Host "`nBackup complete! Files are now syncing to Google Drive." -ForegroundColor Green
