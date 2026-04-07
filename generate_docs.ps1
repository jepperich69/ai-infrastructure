# generate_docs.ps1
# Generates infrastructure_summary.html, infrastructure_full.html,
# infrastructure_summary.pdf, and infrastructure_full.pdf from infrastructure.html.
#
# Usage:  .\generate_docs.ps1 [-SkipPdf]

param(
    [switch]$SkipPdf
)

$aiRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto"
$src    = Join-Path $aiRoot "infrastructure.html"

if (-not (Test-Path $src)) {
    Write-Host "ERR | infrastructure.html not found at: $src" -ForegroundColor Red
    exit 1
}

# ── Read source ────────────────────────────────────────────────────────────────
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

# ── Build replacement blocks ───────────────────────────────────────────────────

# Summary: always hide non-one-pager content (not just on print); also clean up for print
$summaryCss = @(
    "  /* ── Summary mode: always show only the one-pager ── */",
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
    "  /* ── Print: show full document (one-pager hidden) ── */",
    "  @media print {",
    "    body { background: #fff; padding: 20px 24px; }",
    "    .one-pager { display: none !important; }",
    "  }"
)

# ── Helper: splice replacement into line array and write file ──────────────────
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

# ── PDF generation via Edge headless ──────────────────────────────────────────
if (-not $SkipPdf) {
    $edgePaths = @(
        "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
        "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    )
    $edge = $edgePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $edge) {
        Write-Host "  WARN | Microsoft Edge not found; skipping PDF generation." -ForegroundColor Yellow
    } else {
        function Make-Pdf {
            param([string]$htmlPath, [string]$pdfPath)
            $fileUri = "file:///" + ($htmlPath -replace '\\', '/')
            Write-Host "  Generating: $([System.IO.Path]::GetFileName($pdfPath)) ..." -ForegroundColor DarkGray
            & $edge --headless --disable-gpu "--print-to-pdf=$pdfPath" $fileUri 2>$null
            Start-Sleep -Seconds 4  # give Edge time to write the file
            if (Test-Path $pdfPath) {
                Write-Host "  Written: $([System.IO.Path]::GetFileName($pdfPath))" -ForegroundColor Green
            } else {
                Write-Host "  WARN | PDF not found after generation: $pdfPath" -ForegroundColor Yellow
            }
        }

        Make-Pdf -htmlPath $summaryHtml -pdfPath (Join-Path $aiRoot "infrastructure_summary.pdf")
        Make-Pdf -htmlPath $fullHtml    -pdfPath (Join-Path $aiRoot "infrastructure_full.pdf")
    }
}

Write-Host ""
Write-Host "  Done." -ForegroundColor Cyan
