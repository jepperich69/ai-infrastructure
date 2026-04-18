# open_project.ps1
# Compile, then open everything for a project in one shot:
#   - Compile the chosen .tex file
#   - VS Code on Overleaf_source/ with the chosen file
#   - File Explorer on the project root
#   - Freshly compiled PDF
#
# Usage:
#   .\open_project.ps1 -Project Pub_AssesTiming_Raoul_TBA
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project
)

$miktexBin   = "C:\Users\rich\AppData\Local\Programs\MiKTeX\miktex\bin\x64"
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
    $chosen = $texFiles |
        Select-Object Name,
            @{N="Modified"; E={ $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }},
            @{N="KB";        E={ [math]::Round($_.Length / 1KB, 1) }} |
        Out-GridView -Title "Select .tex file  --  $Project" -OutputMode Single

    if ($chosen) {
        $chosenTex = $texFiles | Where-Object { $_.Name -eq $chosen.Name } | Select-Object -First 1
    } else {
        Write-Host "WARN | No file selected -- skipping compile"
    }
}

# ── Compile ───────────────────────────────────────────────────────
$outDir = Join-Path $overleafDir "out"
$pdfPath = $null

if ($chosenTex) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null

    $latexmk  = Join-Path $miktexBin "latexmk.exe"
    $pdflatex = Join-Path $miktexBin "pdflatex.exe"
    $env:BIBINPUTS = "$overleafDir;" + $env:BIBINPUTS
    $env:BSTINPUTS = "$overleafDir;" + $env:BSTINPUTS

    Write-Host "Compiling: $($chosenTex.Name)"

    if (Test-Path $latexmk) {
        $fwd = $pdflatex -replace '\\', '/'
        & $latexmk -pdf -g -f -cd "-pdflatex=$fwd" -interaction=nonstopmode -synctex=1 -outdir="$outDir" $chosenTex.FullName
    } else {
        & $pdflatex -interaction=nonstopmode -synctex=1 -output-directory="$outDir" $chosenTex.FullName
        & $pdflatex -interaction=nonstopmode -synctex=1 -output-directory="$outDir" $chosenTex.FullName
    }

    $compiled = Join-Path $outDir ($chosenTex.BaseName + ".pdf")
    if (Test-Path $compiled) {
        $pdfPath = $compiled
        Write-Host "OK   | Compiled: $($chosenTex.BaseName).pdf"
    } else {
        Write-Host "WARN | Compile failed -- opening VS Code; check the log in out/"
        # Fall back to any existing PDF
        $pdfPath = Get-ChildItem $outDir -Filter "*.pdf" -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
    }
}

# ── Open VS Code ──────────────────────────────────────────────────
if (Test-Path $overleafDir) {
    if ($chosenTex) {
        if (Test-Path $vscode) { & $vscode $overleafDir ($chosenTex.FullName) }
        else { Start-Process "code" """$overleafDir"" ""$($chosenTex.FullName)""" }
    } else {
        if (Test-Path $vscode) { & $vscode $overleafDir }
        else { Start-Process "code" """$overleafDir""" }
    }
    Write-Host "OK   | VS Code opened"
}

# ── Open File Explorer on project root ───────────────────────────
Start-Process explorer.exe $projectRoot
Write-Host "OK   | Explorer opened: $projectRoot"

# ── Open PDF ─────────────────────────────────────────────────────
if ($pdfPath -and (Test-Path $pdfPath)) {
    Start-Process $pdfPath
    Write-Host "OK   | PDF opened: $(Split-Path $pdfPath -Leaf)"
} else {
    Write-Host "INFO | No PDF to open"
}
