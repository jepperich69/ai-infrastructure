# submit.ps1
# Assemble a complete journal submission package.
#
# Called by the /submit skill (after AI content is staged), or run
# standalone via  helpi 17  for the file-operations pass only.
#
# Output folder:  <project>/_submissions/YYYY-MM-DD_<Journal>/
#
#   File naming convention:  <Type>_<Author>_<Journal>_<Year>_<Rev>.*
#
#   Manus_Rich_MPC_2026_R1.pdf       compiled manuscript
#   Frontpage_Rich_MPC_2026_R1.pdf   title page only
#   Package_Rich_MPC_2026_R1.zip     flat .tex (bbl inlined) + figures
#   Package_Blind_MPC_2026_R1.zip    same, author info stripped
#   Manus_Blind_MPC_2026_R1.pdf      compiled blind PDF
#   Diff_Rich_MPC_2026_R1.pdf        latexdiff vs selected original
#   Diff_Rich_MPC_2026_R1.tex        diff source (for manual compile)
#   Cover_Rich_MPC_2026_R1.pdf       from _submit_staging/
#   Highlights_Rich_MPC_2026_R1.txt  from _submit_staging/
#   AuthorStat_Rich_MPC_2026_R1.pdf  from _submit_staging/
#   MANIFEST.txt                     contents summary
#
# Usage:
#   .\submit.ps1 -Project Pub_MIPEntropy_MPC
#   .\submit.ps1 -Project Pub_MIPEntropy_MPC -Journal MPC -TexFile Springer_R1C.tex `
#                -OriginalTexFile Springer_R1B.tex -AuthorAbbr Rich -Revision R1

param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [string]$Journal         = "",      # prompted if omitted
    [string]$TexFile         = "",      # auto-detected if omitted
    [string]$OriginalTexFile = "",      # prompted for diff; skip with -OriginalTexFile SKIP
    [string]$AuthorAbbr      = "Rich",  # first author surname for file naming
    [string]$Revision        = ""       # e.g. R1, R2, Original; auto-detected from TexFile if blank
)

$miktexBin       = "C:\Users\rich\AppData\Local\Programs\MiKTeX\miktex\bin\x64"
$latexdiffScript = "C:\Users\rich\AppData\Local\Programs\MiKTeX\scripts\latexdiff\latexdiff"
$strawberryPerl  = "C:\Strawberry\perl\bin\perl.exe"
$pubRoot         = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$sourceDir       = Join-Path $pubRoot "$Project\Overleaf_source"
$projRoot        = Join-Path $pubRoot $Project

# Locate ghostscript dynamically (version-independent)
$gsExe = Get-ChildItem "C:\Program Files\gs" -Filter "gswin64c.exe" -Recurse -ErrorAction SilentlyContinue |
         Select-Object -First 1 -ExpandProperty FullName

if (!(Test-Path $sourceDir)) {
    Write-Host "ERR  | Overleaf_source not found: $sourceDir" -ForegroundColor Red
    exit 1
}

# -- Journal name -------------------------------------------------------------
if (!$Journal) {
    $Journal = Read-Host "  Journal abbreviation for folder name (e.g. MPC, TRB, EJOR)"
    if (!$Journal) { $Journal = "submission" }
}

# -- Resolve original .tex for diff (prompt first) ----------------------------
$allTex = Get-ChildItem $sourceDir -Filter "*.tex" -File |
          Where-Object { $_.Name -notmatch "^(diff|_diff|manus_R|Response|response|review_log|cover_letter|author_statement)" } |
          Sort-Object LastWriteTime -Descending

if ($OriginalTexFile -eq "") {
    Write-Host ""
    Write-Host "  Select ORIGINAL manuscript .tex (the version before this revision):" -ForegroundColor Cyan
    if ($allTex.Count -eq 0) {
        Write-Host "  WARN | No .tex files found -- diff will be skipped." -ForegroundColor Yellow
        $OriginalTexFile = "SKIP"
    } else {
        $chosen = $allTex |
            Select-Object Name,
                @{N="Modified"; E={ $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }},
                @{N="KB";       E={ [math]::Round($_.Length/1KB,1) }} |
            Out-GridView -Title "Select ORIGINAL manuscript .tex  --  $Project" -OutputMode Single
        if ($chosen) {
            $OriginalTexFile = $chosen.Name
        } else {
            $OriginalTexFile = "SKIP"
            Write-Host "  WARN | No original selected -- diff skipped." -ForegroundColor Yellow
        }
    }
}

# -- Resolve revised .tex (main manuscript) -----------------------------------
if ($TexFile -eq "") {
    if ($allTex.Count -eq 0) {
        Write-Host "ERR  | No .tex files found in $sourceDir" -ForegroundColor Red; exit 1
    } elseif ($allTex.Count -eq 1) {
        $TexFile = $allTex[0].Name
        Write-Host "  INFO | Revised .tex: $TexFile" -ForegroundColor DarkGray
    } else {
        $chosen = $allTex |
            Select-Object Name,
                @{N="Modified"; E={ $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm") }},
                @{N="KB";       E={ [math]::Round($_.Length/1KB,1) }} |
            Out-GridView -Title "Select REVISED manuscript .tex  --  $Project" -OutputMode Single
        if (!$chosen) { Write-Host "Cancelled."; exit 0 }
        $TexFile = $chosen.Name
    }
}

# -- Auto-detect revision label from TexFile name ----------------------------
if (!$Revision) {
    if ($TexFile -match '_R(\d+)') {
        $Revision = "R$($Matches[1])"
    } elseif ($TexFile -match '(?i)orig') {
        $Revision = "Original"
    } else {
        $Revision = Read-Host "  Revision label (e.g. R1, R2, Original)"
        if (!$Revision) { $Revision = "R1" }
    }
}

# -- File naming prefix -------------------------------------------------------
$year        = Get-Date -Format "yyyy"
$prefix      = "${AuthorAbbr}_${Journal}_${year}_${Revision}"
$blindPrefix = "Blind_${Journal}_${year}_${Revision}"

# -- Create output folder -----------------------------------------------------
$stamp  = Get-Date -Format "yyyy-MM-dd"
$outDir = Join-Path $projRoot "_submissions\${stamp}_${Journal}"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
Write-Host ""
Write-Host "  Output: $outDir" -ForegroundColor Cyan
Write-Host "  Prefix: $prefix" -ForegroundColor DarkGray
Write-Host ""

$latexmk  = Join-Path $miktexBin "latexmk.exe"
$pdflatex = Join-Path $miktexBin "pdflatex.exe"
$bibtex   = Join-Path $miktexBin "bibtex.exe"
$texPath  = Join-Path $sourceDir $TexFile
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($TexFile)
$buildDir = Join-Path $sourceDir "out"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

function Step($n, $label) { Write-Host ("  [{0}/7] {1}..." -f $n, $label) -ForegroundColor White }
function OK($msg)          { Write-Host "         OK    $msg" -ForegroundColor Green }
function WARN($msg)        { Write-Host "         WARN  $msg" -ForegroundColor Yellow }
function SKIP($msg)        { Write-Host "         SKIP  $msg" -ForegroundColor DarkGray }

function Get-LatexExternalRefs {
    param([string]$tex)

    $refs = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($pattern in @(
        '\\(?:includegraphics(?:\[[^\]]*\])?)\{([^}]+)\}',
        '\\(?:input|include|subfile)\{([^}]+)\}',
        '\\bibliography\{([^}]+)\}'
    )) {
        foreach ($m in [regex]::Matches($tex, $pattern)) {
            foreach ($part in ($m.Groups[1].Value -split ',')) {
                $name = $part.Trim()
                if ($name) { [void]$refs.Add($name) }
            }
        }
    }

    return @($refs | Sort-Object)
}

# -- Helper: strip author-identifying content from a flat .tex ---------------
function Make-BlindTex {
    param([string]$tex)

    $lines  = $tex -split "`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $blindDepth = 0    # brace-depth counter when inside a blind block
    $inAck      = $false

    # Commands whose entire {...} block should be commented out
    $triggerPattern = '\\(author|institute|affiliation|address|thanks|email|ead|cortext|fntext|corref|fnref)\s*\{'

    foreach ($line in $lines) {
        # Detect start/end of acknowledgements section
        if ($line -match '\\section\*?\s*\{[Aa]cknowledg') {
            $inAck = $true
        } elseif ($inAck -and $line -match '(\\section|\\end\s*\{document\})') {
            $inAck = $false
        }

        $shouldBlind = $inAck

        if (!$shouldBlind -and $blindDepth -gt 0) {
            # Continuation line of an already-open blind block
            $shouldBlind = $true
            foreach ($ch in $line.ToCharArray()) {
                if     ($ch -eq '{') { $blindDepth++ }
                elseif ($ch -eq '}') { $blindDepth--; if ($blindDepth -eq 0) { break } }
            }
        } elseif (!$shouldBlind -and $line -match $triggerPattern) {
            # Opening line of a new blind block -- scan brace depth
            $shouldBlind = $true
            $triggered   = $false
            foreach ($ch in $line.ToCharArray()) {
                if (!$triggered -and $ch -eq '{') {
                    $triggered  = $true
                    $blindDepth = 1
                } elseif ($triggered) {
                    if     ($ch -eq '{') { $blindDepth++ }
                    elseif ($ch -eq '}') { $blindDepth--; if ($blindDepth -eq 0) { break } }
                }
            }
            # blindDepth = 0 means block closed on this line (single-line command)
        }

        $result.Add( $(if ($shouldBlind) { "% [BLIND] $line" } else { $line }) )
    }

    return $result -join "`n"
}

# -- [1] Compile --------------------------------------------------------------
Step 1 "Compiling manuscript"
$env:BIBINPUTS  = "$sourceDir;" + $env:BIBINPUTS
$env:BSTINPUTS  = "$sourceDir;" + $env:BSTINPUTS   # needed for .bst files (e.g. spmpsci.bst) in sourceDir
if (Test-Path $latexmk) {
    $fwd = $pdflatex -replace '\\', '/'
    & $latexmk -pdf -g -f -cd "-pdflatex=$fwd" -interaction=nonstopmode -outdir="$buildDir" "$texPath" *>$null
} else {
    & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$texPath" *>$null
    & $bibtex   (Join-Path $buildDir $baseName)                                   *>$null
    & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$texPath" *>$null
    & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$texPath" *>$null
}
$manuscriptPdf = Join-Path $buildDir "$baseName.pdf"
$manuscriptOut = Join-Path $outDir   "Manus_${prefix}.pdf"
if (Test-Path $manuscriptPdf) {
    Copy-Item $manuscriptPdf $manuscriptOut -Force
    OK "Manus_${prefix}.pdf"
} else {
    WARN "Compilation failed -- check $buildDir\$baseName.log"
}

# -- [2] Front page -----------------------------------------------------------
Step 2 "Extracting front page (page 1)"
$srcPdf    = $manuscriptOut
$frontOut  = Join-Path $outDir "Frontpage_${prefix}.pdf"
$extracted = $false
if (Test-Path $srcPdf) {
    $pdftk = Get-Command pdftk -ErrorAction SilentlyContinue
    if ($pdftk) {
        try {
            & pdftk $srcPdf cat 1 output $frontOut 2>$null
            if (Test-Path $frontOut) { OK "Frontpage_${prefix}.pdf (pdftk)"; $extracted = $true }
        } catch {}
    }
    if (!$extracted -and $gsExe -and (Test-Path $gsExe)) {
        try {
            & $gsExe -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dFirstPage=1 -dLastPage=1 `
                -sOutputFile="$frontOut" "$srcPdf" 2>$null
            if (Test-Path $frontOut) { OK "Frontpage_${prefix}.pdf (ghostscript)"; $extracted = $true }
        } catch {}
    }
    if (!$extracted) { WARN "pdftk and ghostscript not available -- front-page skipped" }
} else {
    SKIP "no manuscript PDF to extract from"
}

# -- [3] Inline bibliography into flat .tex -----------------------------------
# Use [regex]::Replace with a MatchEvaluator for the bbl substitution so that
# $ characters inside bbl entries (e.g. math in titles) are never treated as
# regex back-references by PowerShell's -replace operator.
Step 3 "Inlining bibliography into flat .tex"
$bblFile = Join-Path $buildDir "$baseName.bbl"
$flatTex = Join-Path $outDir "Package_${prefix}.tex"
if ((Test-Path $bblFile) -and (Get-Item $bblFile).Length -gt 0) {
    $texSrc  = Get-Content $texPath -Raw -Encoding UTF8
    $bbl     = Get-Content $bblFile -Raw -Encoding UTF8
    $texSrc  = $texSrc -replace '(?m)^[ \t]*\\bibliographystyle\{[^}]+\}[ \t]*\r?\n?', ''
    $bblSnap = $bbl   # capture for MatchEvaluator closure
    $texSrc  = [regex]::Replace($texSrc, '\\bibliography\{[^}]+\}', { param($m) $bblSnap })
    Set-Content -Path $flatTex -Value $texSrc -Encoding UTF8
    OK "Package_${prefix}.tex  (bbl inlined, $((($bbl -split '\n').Count)) ref lines)"
} else {
    Copy-Item $texPath $flatTex -Force
    WARN ".bbl not found -- flat .tex is unmodified copy"
}
$flatTexContent = Get-Content $flatTex -Raw -Encoding UTF8   # keep in memory for blind step

# -- [4] Submission zip (sighted) --------------------------------------------
Step 4 "Creating submission zip"
$zipPath = Join-Path $outDir "Package_${prefix}.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
# Include flat tex as main.tex inside the zip
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $flatTex, "main.tex") | Out-Null
$extras = Get-ChildItem $sourceDir -File |
          Where-Object { $_.Extension -match '\.(png|pdf|eps|jpg|jpeg|sty|cls)$' }
foreach ($f in $extras) {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $f.Name) | Out-Null
}
$zip.Dispose()
$nZip = $extras.Count + 1
OK "Package_${prefix}.zip  ($nZip files, tex as main.tex)"

# -- [5] Blind manuscript + zip -----------------------------------------------
Step 5 "Creating blind manuscript"
$blindTexContent = Make-BlindTex -tex $flatTexContent
$blindTexSrc     = Join-Path $sourceDir "_blind_tmp.tex"   # compile from sourceDir
$blindTexOut     = Join-Path $outDir    "Package_${blindPrefix}.tex"
Set-Content -Path $blindTexSrc  -Value $blindTexContent -Encoding UTF8
Set-Content -Path $blindTexOut  -Value $blindTexContent -Encoding UTF8

# Compile blind PDF
if (Test-Path $latexmk) {
    $fwd = $pdflatex -replace '\\', '/'
    & $latexmk -pdf -g -f -cd "-pdflatex=$fwd" -interaction=nonstopmode -outdir="$buildDir" "$blindTexSrc" *>$null
} else {
    & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$blindTexSrc" *>$null
    & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$blindTexSrc" *>$null
}
$blindPdfSrc = Join-Path $buildDir "_blind_tmp.pdf"
if (Test-Path $blindPdfSrc) {
    Copy-Item $blindPdfSrc (Join-Path $outDir "Manus_${blindPrefix}.pdf") -Force
    OK "Manus_${blindPrefix}.pdf"
} else {
    WARN "Blind PDF compile failed -- Package_${blindPrefix}.tex is in the folder; check manually"
}

# Blind zip
$blindZip = Join-Path $outDir "Package_${blindPrefix}.zip"
if (Test-Path $blindZip) { Remove-Item $blindZip -Force }
$zipB = [System.IO.Compression.ZipFile]::Open($blindZip, 'Create')
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipB, $blindTexSrc, "main.tex") | Out-Null
foreach ($f in $extras) {
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipB, $f.FullName, $f.Name) | Out-Null
}
$zipB.Dispose()
OK "Package_${blindPrefix}.zip  ($nZip files, author info stripped)"

# Clean up blind temp files from sourceDir
Remove-Item $blindTexSrc -Force -ErrorAction SilentlyContinue
@(".aux",".log",".out",".fls",".fdb_latexmk",".bbl",".blg") | ForEach-Object {
    $f = Join-Path $buildDir "_blind_tmp$_"
    if (Test-Path $f) { Remove-Item $f -Force }
}

# -- [6] LaTeX diff -----------------------------------------------------------
# diff.tex is compiled from $sourceDir so latexmk finds the class, styles,
# and figures. Bibliography is inlined from the .bbl to avoid a bibtex run.
#
# IMPORTANT: line-ending normalisation.
# Files saved on Windows (CRLF) vs Overleaf/Linux (LF) differ on every line,
# so latexdiff cannot find common anchors and silently drops changes.
# We write LF-only temp copies and diff those instead of the originals.
#
# IMPORTANT: scope.
# latexdiff only compares LaTeX source. Even with --flatten, changes inside
# external assets (.png, .pdf, .bib, .cls, .sty) are not marked unless the
# corresponding reference line in the .tex changed.
#
# IMPORTANT: float stability.
# Figure/table diffs are more fragile than text diffs. We therefore run
# latexdiff in a conservative mode that avoids graphics highlighting and
# other markup that tends to disturb float placement.
Step 6 "Generating LaTeX diff"
if ($OriginalTexFile -ne "SKIP") {
    $origPath    = Join-Path $sourceDir $OriginalTexFile
    $origNorm    = Join-Path $sourceDir "_orig_norm_tmp.tex"
    $revisedNorm = Join-Path $sourceDir "_revised_norm_tmp.tex"
    $origNormBbl = Join-Path $sourceDir "_orig_norm_tmp.bbl"
    $revisedNormBbl = Join-Path $sourceDir "_revised_norm_tmp.bbl"
    $diffTexSrc  = Join-Path $sourceDir "_diff_tmp.tex"    # compiled here for dependency access
    $diffTexOut  = Join-Path $outDir    "Diff_${prefix}.tex"
    $diffNoteOut = Join-Path $outDir    "Diff_${prefix}_NOTES.txt"
    $latexdiffErr = Join-Path $buildDir "_diff_tmp_latexdiff.err"
    $latexdiffArgs = @(
        '--flatten',
        '--graphics-markup=none',
        '--disable-citation-markup',
        '--floattype=FLOATSAFE',
        $origNorm,
        $revisedNorm
    )
    try {
        # Normalise both files to LF before diffing
        $origText    = [System.IO.File]::ReadAllText($origPath, [System.Text.Encoding]::UTF8) -replace "`r`n","`n"
        $revisedText = [System.IO.File]::ReadAllText($texPath,  [System.Text.Encoding]::UTF8) -replace "`r`n","`n"
        [System.IO.File]::WriteAllText($origNorm,    $origText,    [System.Text.Encoding]::UTF8)
        [System.IO.File]::WriteAllText($revisedNorm, $revisedText, [System.Text.Encoding]::UTF8)

        # --flatten expects sidecar .bbl files matching the temp .tex basenames.
        if ((Test-Path $bblFile) -and (Get-Item $bblFile).Length -gt 0) {
            Copy-Item $bblFile $origNormBbl -Force
            Copy-Item $bblFile $revisedNormBbl -Force
        }

        if (Test-Path $latexdiffErr) { Remove-Item $latexdiffErr -Force }
        $result      = & $strawberryPerl $latexdiffScript @latexdiffArgs 2> $latexdiffErr
        $diffContent = $result | Out-String
        if (Test-Path $latexdiffErr) {
            $stderrLines = Get-Content $latexdiffErr -Encoding UTF8 | Where-Object {
                $_ -and
                $_ -notmatch '^kpsewhich:' -and
                $_ -notmatch 'cannot be found\. No flattening of' -and
                $_ -notmatch '^Bibliography file '
            }
            if ($stderrLines.Count -gt 0) {
                WARN ("latexdiff reported warnings; see {0}" -f (Split-Path $latexdiffErr -Leaf))
            }
        }

        # Inline bibliography so the diff compiles without a bibtex run.
        # Use [regex]::Replace + MatchEvaluator so $ in bbl entries isn't
        # misread as a capture-group back-reference.
        if ((Test-Path $bblFile) -and (Get-Item $bblFile).Length -gt 0) {
            $bbl         = Get-Content $bblFile -Raw -Encoding UTF8
            $bblSnap2    = $bbl
            $diffContent = $diffContent -replace '(?m)^[ \t]*\\bibliographystyle\{[^}]+\}[ \t]*\r?\n?', ''
            $diffContent = [regex]::Replace($diffContent, '\\bibliography\{[^}]+\}', { param($m) $bblSnap2 })
        }

        Set-Content -Path $diffTexSrc -Value $diffContent -Encoding UTF8
        Copy-Item $diffTexSrc $diffTexOut -Force

        $origRefs    = Get-LatexExternalRefs -tex $origText
        $revisedRefs = Get-LatexExternalRefs -tex $revisedText
        $allRefs     = @($origRefs + $revisedRefs | Sort-Object -Unique)
        if ($allRefs.Count -gt 0) {
            $noteLines = @(
                "LaTeX diff scope note",
                "Original: $OriginalTexFile",
                "Revised:  $TexFile",
                "",
                "latexdiff compares LaTeX source only.",
                "It does not highlight content changes inside external files unless the LaTeX reference line changed.",
                "",
                "Referenced external items detected in these manuscripts:"
            ) + ($allRefs | ForEach-Object { "  - $_" })
            Set-Content -Path $diffNoteOut -Value ($noteLines -join "`r`n") -Encoding UTF8
            WARN "LaTeX diff is source-only; see $(Split-Path $diffNoteOut -Leaf) for referenced external files"
        }

        if (Test-Path $latexmk) {
            $fwd = $pdflatex -replace '\\', '/'
            & $latexmk -pdf -g -f -cd "-pdflatex=$fwd" -interaction=nonstopmode -outdir="$buildDir" "$diffTexSrc" *>$null
        } else {
            & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$diffTexSrc" *>$null
            & $pdflatex -interaction=nonstopmode -output-directory="$buildDir" "$diffTexSrc" *>$null
        }
        $diffPdf = Join-Path $buildDir "_diff_tmp.pdf"
        if (Test-Path $diffPdf) {
            Copy-Item $diffPdf (Join-Path $outDir "Diff_${prefix}.pdf") -Force
            OK "Diff_${prefix}.pdf  (vs $OriginalTexFile)"
        } else {
            WARN "Diff PDF compile failed -- Diff_${prefix}.tex is in the folder; compile in Overleaf"
        }
    } catch {
        WARN "latexdiff failed: $_"
    } finally {
        foreach ($tmp in @($diffTexSrc, $origNorm, $revisedNorm, $origNormBbl, $revisedNormBbl, $latexdiffErr)) {
            if (Test-Path $tmp) { Remove-Item $tmp -Force }
        }
        @(".aux",".log",".out",".fls",".fdb_latexmk",".bbl",".blg") | ForEach-Object {
            $f = Join-Path $buildDir "_diff_tmp$_"
            if (Test-Path $f) { Remove-Item $f -Force }
        }
    }
} else {
    SKIP "diff skipped"
}

# -- [7] AI-generated content -------------------------------------------------
Step 7 "Copying AI-generated content"
$staging = Join-Path $projRoot "_submit_staging"
$aiMap   = [ordered]@{
    "cover_letter.pdf"    = "Cover_${prefix}.pdf"
    "highlights.txt"      = "Highlights_${prefix}.txt"
    "author_statement.pdf"= "AuthorStat_${prefix}.pdf"
}
$nCopied = 0
foreach ($entry in $aiMap.GetEnumerator()) {
    $src = Join-Path $staging $entry.Key
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $outDir $entry.Value) -Force
        OK $entry.Value
        $nCopied++
    }
}
if ($nCopied -eq 0) {
    SKIP "no staged content -- run /submit to generate cover letter, highlights, author statement"
}

# -- Manifest -----------------------------------------------------------------
$items = Get-ChildItem $outDir -File | Sort-Object Name
$lines = $items | ForEach-Object { "  {0,-55} {1,7} KB" -f $_.Name, [math]::Round($_.Length/1KB,1) }
$origLabel = if ($OriginalTexFile -eq "SKIP") { "N/A" } else { $OriginalTexFile }
$manifestText = @"
Submission package
Project:  $Project
Journal:  $Journal
Main:     $TexFile
Original: $origLabel
Prefix:   $prefix
Date:     $(Get-Date -Format "yyyy-MM-dd HH:mm")

Contents:
$($lines -join "`n")
"@
Set-Content (Join-Path $outDir "MANIFEST.txt") $manifestText -Encoding UTF8

Write-Host ""
Write-Host "  Submission package complete  [$prefix]" -ForegroundColor Cyan
Write-Host ($lines -join "`n")
Write-Host ""
Start-Process $outDir
