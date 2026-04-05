# open_project.ps1
# Open everything for a project in one shot:
#   - VS Code on Overleaf_source/ with a chosen .tex file
#   - File Explorer on the project root
#   - Latest compiled PDF (if it exists)
#
# The .tex file is selected via a graphical picker (Out-GridView).
# If only one .tex file exists it opens directly without prompting.
#
# Usage:
#   .\open_project.ps1 -Project Pub_AssesTiming_Raoul_TBA
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$pubRoot     = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$vscode      = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
$projectRoot = Join-Path $pubRoot $Project
$overleafDir = Join-Path $projectRoot "Overleaf_source"

if (!(Test-Path $projectRoot)) {
    Write-Host "ERR  | Project not found: $projectRoot"
    exit 1
}

# ── Pick .tex file ────────────────────────────────────────────────
$texFiles = @()
if (Test-Path $overleafDir) {
    $texFiles = Get-ChildItem $overleafDir -Filter "*.tex" -File |
                Sort-Object LastWriteTime -Descending
}

$chosenTex = $null
if ($texFiles.Count -eq 0) {
    Write-Host "WARN | No .tex files found in Overleaf_source/"
} elseif ($texFiles.Count -eq 1) {
    $chosenTex = $texFiles[0]
    Write-Host "OK   | Single .tex file: $($chosenTex.Name)"
} else {
    # Graphical picker
    $chosen = $texFiles |
        Select-Object Name,
            @{N="Modified"; E={ $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }},
            @{N="KB";        E={ [math]::Round($_.Length / 1KB, 1) }} |
        Out-GridView -Title "Select .tex file to open  --  $Project" -OutputMode Single

    if ($chosen) {
        $chosenTex = $texFiles | Where-Object { $_.Name -eq $chosen.Name } | Select-Object -First 1
    } else {
        Write-Host "WARN | No file selected -- opening VS Code without a specific file"
    }
}

# ── Open VS Code ──────────────────────────────────────────────────
if (Test-Path $overleafDir) {
    $codeTarget = $overleafDir
    if ($chosenTex) {
        # Open the folder first, then the specific file
        if (Test-Path $vscode) {
            & $vscode $overleafDir ($chosenTex.FullName)
        } else {
            Start-Process "code" """$overleafDir"" ""$($chosenTex.FullName)"""
        }
    } else {
        if (Test-Path $vscode) { & $vscode $overleafDir }
        else { Start-Process "code" """$overleafDir""" }
    }
    Write-Host "OK   | VS Code opened"
}

# ── Open File Explorer on project root ───────────────────────────
Start-Process explorer.exe $projectRoot
Write-Host "OK   | Explorer opened: $projectRoot"

# ── Open latest PDF if it exists ─────────────────────────────────
$pdf = Get-ChildItem (Join-Path $overleafDir "out") -Filter "*.pdf" -ErrorAction SilentlyContinue |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$pdf) {
    # Also check Overleaf_source root (some setups put pdf there)
    $pdf = Get-ChildItem $overleafDir -Filter "*.pdf" -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if ($pdf) {
    Start-Process $pdf.FullName
    Write-Host "OK   | PDF opened: $($pdf.Name)"
} else {
    Write-Host "INFO | No compiled PDF found yet -- run helpi 3 $Project to compile"
}
