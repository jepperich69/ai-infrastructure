# compile_latex.ps1
# Compile the main .tex file for a project and open the resulting PDF.
#
# Usage:
#   .\compile_latex.ps1 -Project Pub_AssesTiming_Raoul_TBA
#   .\compile_latex.ps1 -Project Pub_AssesTiming_Raoul_TBA -TexFile custom.tex
#
param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [string]$TexFile = ""   # auto-detected if omitted
)

. "$PSScriptRoot\config.ps1"
$projectRoot = Resolve-ProjectRoot $Project
$sourceDir = Join-Path $projectRoot "Overleaf_source"

if (!(Test-Path $sourceDir)) {
    Write-Host "ERR  | Overleaf_source not found: $sourceDir"
    exit 1
}

# Resolve .tex file
if ($TexFile -eq "") {
    $candidates = Get-ChildItem $sourceDir -Filter "*.tex" -File |
                  Sort-Object LastWriteTime -Descending

    if ($candidates.Count -eq 0) {
        Write-Host "ERR  | No .tex files found in $sourceDir"
        exit 1
    } elseif ($candidates.Count -eq 1) {
        $TexFile = $candidates[0].Name
        Write-Host "INFO | Single .tex file found: $TexFile"
    } else {
        # Graphical picker
        $chosen = $candidates |
            Select-Object Name,
                @{N="Modified"; E={ $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }},
                @{N="KB";        E={ [math]::Round($_.Length / 1KB, 1) }} |
            Out-GridView -Title "Select .tex file to compile  --  $Project" -OutputMode Single

        if (!$chosen) {
            Write-Host "Cancelled."
            exit 0
        }
        $TexFile = $chosen.Name
    }
}

$texPath = Join-Path $sourceDir $TexFile
if (!(Test-Path $texPath)) {
    Write-Host "ERR  | File not found: $texPath"
    exit 1
}

$outDir = Join-Path $sourceDir "out"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

Write-Host "Compiling: $TexFile"
Write-Host "Output to: $outDir"
Write-Host ""

$latexmk = Join-Path $miktexBin "latexmk.exe"
$pdflatex = Join-Path $miktexBin "pdflatex.exe"

# Use latexmk if available (handles bibliography passes automatically), else pdflatex
$env:BIBINPUTS = "$sourceDir;" + $env:BIBINPUTS

if (Test-Path $latexmk) {
    $pdflatexFwd = $pdflatex -replace '\\', '/'
    & $latexmk -pdf -g -f -cd "-pdflatex=$pdflatexFwd" -interaction=nonstopmode -synctex=1 -outdir="$outDir" "$texPath"
} else {
    & $pdflatex -interaction=nonstopmode -synctex=1 -output-directory="$outDir" "$texPath"
    & $pdflatex -interaction=nonstopmode -synctex=1 -output-directory="$outDir" "$texPath"
}

$pdfPath = Join-Path $outDir ($TexFile -replace "\.tex$", ".pdf")
if ($LASTEXITCODE -ne 0) {
    if (Test-Path $pdfPath) {
        Write-Host ""
        Write-Host "WARN | Compilation finished with warnings (missing figures/refs). Opening PDF anyway."
    } else {
        Write-Host ""
        Write-Host "ERR  | Compilation failed. Check the log:"
        Write-Host "       $(Join-Path $outDir ($TexFile -replace '\.tex$', '.log'))"
        exit 1
    }
}

# Open PDF
if (Test-Path $pdfPath) {
    Write-Host ""
    Write-Host "OK   | Opening: $pdfPath"
    Start-Process $pdfPath
} else {
    Write-Host "ERR  | PDF not found after compilation: $pdfPath"
    exit 1
}
