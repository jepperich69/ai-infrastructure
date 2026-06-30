# generate_docs.ps1
# Generates infrastructure_summary.html, infrastructure_full.html,
# infrastructure_summary.pdf, and infrastructure_full.pdf from infrastructure.html.
#
# Usage:  .\generate_docs.ps1 [-SkipPdf]

param(
    [switch]$SkipPdf
)

. "$PSScriptRoot\config.ps1"
$src    = Join-Path $aiRoot "infrastructure.html"

if (-not (Test-Path $src)) {
    Write-Host "ERR | infrastructure.html not found at: $src" -ForegroundColor Red
    exit 1
}

# â”€â”€ Read source â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$lines = Get-Content $src -Encoding UTF8

# Find the @media print block boundaries (search for the known comment line)
$blockStart = -1
$blockEnd   = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'Print: show ONLY the one-pager') {
        $blockStart = $i
    }
    if ($blockStart -ge 0 -and $i -gt $blockStart -and $lines[$i] -match '^\s*\}\s*$') {
        $blockEnd = $i
        break
    }
}

if ($blockStart -lt 0 -or $blockEnd -lt 0) {
    Write-Host "ERR | Could not locate @media print block in infrastructure.html" -ForegroundColor Red
    exit 1
}

Write-Host "  Found @media print block at lines $($blockStart+1)-$($blockEnd+1)" -ForegroundColor DarkGray

# â”€â”€ Build replacement blocks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

# Summary: always hide non-one-pager content (not just on print); also clean up for print
$summaryCss = @(
    "  /* -- Summary mode: always show only the one-pager -- */",
    "  .page > *:not(.one-pager) { display: none !important; }",
    "  .one-pager .op-print-note { display: none; }",
    "  @media print {",
    "    body { background: #fff; padding: 0; }",
    "    .one-pager { border: none; border-radius: 0; padding: 10px 0; margin: 0;",
    "                 box-shadow: none; page-break-inside: avoid; }",
    "    .one-pager h1 { font-size: 1.15em; }",
    "  }"
)

# Full: print shows everything; one-pager goes last so it stays at end
$fullCss = @(
    "  /* -- Print: show full document (one-pager hidden) -- */",
    "  @media print {",
    "    body { background: #fff; padding: 20px 24px; }",
    "    .one-pager { display: none !important; }",
    "  }"
)

# â”€â”€ Helper: splice replacement into line array and write file â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function Write-Spliced {
    param([string[]]$srcLines, [int]$start, [int]$end, [string[]]$replacement, [string]$outPath)
    $out = @()
    $out += $srcLines[0..($start - 1)]
    $out += $replacement
    $out += $srcLines[($end + 1)..($srcLines.Count - 1)]
    $out | Set-Content -Path $outPath -Encoding UTF8
}

$summaryHtml = Join-Path $aiRoot "infrastructure_summary.html"
$fullHtml    = Join-Path $aiRoot "infrastructure_full.html"

Write-Spliced -srcLines $lines -start $blockStart -end $blockEnd -replacement $summaryCss -outPath $summaryHtml
Write-Host "  Written: infrastructure_summary.html" -ForegroundColor Green

Write-Spliced -srcLines $lines -start $blockStart -end $blockEnd -replacement $fullCss -outPath $fullHtml
Write-Host "  Written: infrastructure_full.html" -ForegroundColor Green

# â”€â”€ PDF generation via Edge headless â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if (-not $SkipPdf) {
    $edgePaths = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
    $edge = $edgePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $edge) {
        Write-Host "  WARN | Microsoft Edge not found; skipping PDF generation." -ForegroundColor Yellow
    } else {
        # Isolated, throwaway Edge profile. Without --user-data-dir, a normal Edge
        # window already open on the machine intercepts the headless --print-to-pdf
        # call and serves a STALE cached render: the .pdf gets a fresh timestamp but
        # old content (looks regenerated, silently is not). A dedicated profile spawns
        # an independent instance that cannot share the running browser's cache, and
        # does not disturb the user's open windows. See known_issues.md #41.
        $edgeProfile = Join-Path $env:TEMP ("edgepdf_" + [guid]::NewGuid().ToString("N"))

        function Make-Pdf {
            param([string]$htmlPath, [string]$pdfPath, [string]$profileDir, [string]$edgeExe)
            $fileUri = "file:///" + ($htmlPath -replace '\\', '/')
            Write-Host "  Generating: $([System.IO.Path]::GetFileName($pdfPath)) ..." -ForegroundColor DarkGray
            # Delete any prior PDF first so a failed render can never masquerade as fresh.
            if (Test-Path $pdfPath) { Remove-Item -LiteralPath $pdfPath -Force }
            $edgeArgs = @(
                "--headless", "--disable-gpu", "--no-first-run", "--disable-extensions",
                "--user-data-dir=$profileDir", "--print-to-pdf=$pdfPath", $fileUri
            )
            & $edgeExe @edgeArgs 2>$null
            # The isolated profile's first run is slower; poll up to 30s for the file.
            $waited = 0
            while (-not (Test-Path $pdfPath) -and $waited -lt 30) {
                Start-Sleep -Seconds 1; $waited++
            }
            if (Test-Path $pdfPath) {
                Write-Host "  Written: $([System.IO.Path]::GetFileName($pdfPath))" -ForegroundColor Green
            } else {
                Write-Host "  WARN | PDF not found after generation: $pdfPath" -ForegroundColor Yellow
            }
        }

        Make-Pdf -htmlPath $summaryHtml -pdfPath (Join-Path $aiRoot "infrastructure_summary.pdf") -profileDir $edgeProfile -edgeExe $edge
        Make-Pdf -htmlPath $fullHtml    -pdfPath (Join-Path $aiRoot "infrastructure_full.pdf")    -profileDir $edgeProfile -edgeExe $edge

        # Clean up the throwaway profile.
        if (Test-Path -LiteralPath $edgeProfile) {
            Remove-Item -LiteralPath $edgeProfile -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host ""
Write-Host "  Done." -ForegroundColor Cyan
