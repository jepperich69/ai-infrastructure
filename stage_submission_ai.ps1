param(
    [Parameter(Mandatory=$true)]
    [string]$Project,

    [string]$Journal = "",
    [string]$TexFile = "",
    [string]$AuthorAbbr = "Rich"
)

. "$PSScriptRoot\config.ps1"

$projRoot  = Join-Path $pubRoot $Project
$sourceDir = Join-Path $projRoot "Overleaf_source"
$briefPath = Join-Path $projRoot ".claude\CLAUDE.md"
$staging   = Join-Path $projRoot "_submit_staging"

if (!(Test-Path $sourceDir)) {
    Write-Host "ERR  | Overleaf_source not found: $sourceDir" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $staging -Force | Out-Null

function Get-MatchText([string]$text, [string]$pattern) {
    $m = [regex]::Match($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if ($m.Success) { return $m.Groups[1].Value.Trim() }
    return ""
}

function Strip-Latex([string]$s) {
    if (!$s) { return "" }
    $s = $s -replace '\\&', '&'
    $s = $s -replace '--', '-'
    $s = $s -replace '\\emph\{([^}]*)\}', '$1'
    $s = $s -replace '\\texorpdfstring\{([^}]*)\}\{([^}]*)\}', '$2'
    $s = $s -replace '\\[a-zA-Z]+\*?(?:\[[^\]]*\])?(?:\{([^}]*)\})?', '$1'
    $s = $s -replace '[{}$]', ''
    $s = $s -replace '\s+', ' '
    return $s.Trim()
}

function Escape-Latex([string]$s) {
    if (!$s) { return "" }
    $s = $s -replace '\\', '\textbackslash{}'
    $s = $s -replace '&', '\&'
    $s = $s -replace '%', '\%'
    $s = $s -replace '#', '\#'
    $s = $s -replace '_', '\_'
    return $s
}

function Shorten-Highlight([string]$s) {
    $s = (Strip-Latex $s).Trim().TrimEnd('.')
    $repl = [ordered]@{
        "Three-stage pipeline" = "Pipeline"
        "KL-optimal integerization" = "KL integerization"
        "Metropolis--Hastings" = "MH"
        "Metropolis-Hastings" = "MH"
        "near-optimal space" = "near-optimal set"
        "near-optimal landscape" = "Near-optimal landscape"
        "prediction uncertainty" = "uncertainty"
        "information guarantees" = "information structure"
        "transparent classifiers" = "transparent classifiers"
        "rule inclusion probabilities" = "rule inclusion probabilities"
        " at no extra cost" = ""
    }
    foreach ($k in $repl.Keys) { $s = $s -replace [regex]::Escape($k), $repl[$k] }
    if ($s.Length -le 83) { return "* $s" }
    $max = 83
    $cut = $s.Substring(0, [Math]::Min($s.Length, $max))
    $lastSpace = $cut.LastIndexOf(' ')
    if ($lastSpace -gt 50) { $cut = $cut.Substring(0, $lastSpace) }
    return "* $($cut.Trim().TrimEnd(',;:'))"
}

$brief = if (Test-Path $briefPath) { Get-Content -LiteralPath $briefPath -Raw -Encoding UTF8 } else { "" }

if (!$TexFile -and $brief -match '\*\*Main manuscript:\*\*\s*`([^`]+)`') {
    $TexFile = $Matches[1]
}
if (!$TexFile) {
    $TexFile = (Get-ChildItem $sourceDir -Filter "*.tex" -File |
        Where-Object { $_.Name -notmatch "^(diff|_diff|manus_R|Response|response|review_log|cover_letter|author_statement)" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1).Name
}
if (!$TexFile) {
    Write-Host "ERR  | No manuscript .tex found in $sourceDir" -ForegroundColor Red
    exit 1
}

$texPath = Join-Path $sourceDir $TexFile
$tex     = Get-Content -LiteralPath $texPath -Raw -Encoding UTF8

if (!$Journal) {
    if ($brief -match '\*\*Target journal:\*\*\s*([^\r\n]+)') {
        $Journal = $Matches[1].Trim()
    } elseif ($brief -match 'Primary target venue:\s*([^\.\r\n]+)') {
        $Journal = $Matches[1].Trim()
    } else {
        $Journal = "the target journal"
    }
}

$title = Strip-Latex (Get-MatchText $tex '\\title\s*\{([^}]*)\}')
if (!$title) { $title = [System.IO.Path]::GetFileNameWithoutExtension($TexFile) }

$authorRaw = Get-MatchText $tex '\\author(?:\[[^\]]*\])?\s*\{([^}]*)\}'
$author = Strip-Latex ($authorRaw -replace '\\corref\{[^}]+\}', '')
if (!$author) { $author = $AuthorAbbr }

$email = Get-MatchText $tex '\\ead\s*\{([^}]*)\}'
if (!$email -and $brief -match '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}') { $email = $Matches[0] }

$abstract = Strip-Latex (Get-MatchText $tex '\\begin\{abstract\}(.*?)\\end\{abstract\}')
$firstAbs = ($abstract -split '(?<=[.!?])\s+' | Select-Object -First 2) -join ' '

$highlightItems = @()
$hBlock = Get-MatchText $tex '\\begin\{highlights\}(.*?)\\end\{highlights\}'
if ($hBlock) {
    $highlightItems = @([regex]::Matches($hBlock, '(?m)\\item\s+(.+)$') | ForEach-Object { Shorten-Highlight $_.Groups[1].Value })
}
if ($highlightItems.Count -lt 5) {
    $highlightItems = @(
        "* Transparent decision rules are framed as discrete optimization objects.",
        "* Soft probabilistic scores are converted into hard commitments.",
        "* The method returns both a strong incumbent and uncertainty measures.",
        "* Experiments test solution quality, scalability, and stability.",
        "* The framework supports auditability and sensitivity analysis."
    )
}
$highlightItems = $highlightItems | Select-Object -First 5

$coverPath = Join-Path $staging "cover_letter.tex"
$coverPdf  = Join-Path $staging "cover_letter.pdf"
$highPath  = Join-Path $staging "highlights.txt"
$authPath  = Join-Path $staging "author_statement.tex"
$authPdf   = Join-Path $staging "author_statement.pdf"

$journalTex = Escape-Latex $Journal
$titleTex   = Escape-Latex $title
$authorTex  = Escape-Latex $author
$emailTex   = Escape-Latex $email
$firstAbsTex = Escape-Latex $firstAbs

$cover = @"
\documentclass[12pt]{article}
\usepackage[top=2.5cm,bottom=2.5cm,left=3cm,right=3cm]{geometry}
\usepackage{parskip}
\usepackage{microtype}
\begin{document}
\raggedright

\today

\bigskip
The Editor-in-Chief \\
\textit{$journalTex}

\bigskip
Dear Editor,

I submit the manuscript ``$titleTex'' for consideration in \textit{$journalTex}.

$firstAbsTex This fits the journal's scope because the contribution is a
computational method for structured decision models, with emphasis on
scalability, heuristic design, and solution-space analysis.

The manuscript contributes a transparent discrete optimization framework,
combines soft probabilistic scoring with hard feasible commitment, and reports
computational evidence on solution quality, uncertainty, and stability.

The manuscript has not been previously published and is not under
consideration for publication elsewhere. All authors have read and approved
the final manuscript.

\bigskip
Sincerely,

\bigskip
$authorTex \\
Technical University of Denmark \\
$emailTex

\end{document}
"@
Set-Content -LiteralPath $coverPath -Value $cover -Encoding UTF8
Set-Content -LiteralPath $highPath -Value ($highlightItems -join "`r`n") -Encoding UTF8

$auth = @"
\documentclass[12pt]{article}
\usepackage[margin=2.5cm]{geometry}
\usepackage{parskip}
\begin{document}

\section*{Author Contributions}

\textbf{${authorTex}:} Conceptualization, Methodology, Software, Validation,
Formal analysis, Investigation, Data Curation, Writing -- Original Draft,
Writing -- Review \& Editing, Visualization.

\end{document}
"@
Set-Content -LiteralPath $authPath -Value $auth -Encoding UTF8

$pdflatex = Join-Path $miktexBin "pdflatex.exe"
if (Test-Path $pdflatex) {
    & $pdflatex -interaction=nonstopmode -output-directory "$staging" "$coverPath" *> $null
    & $pdflatex -interaction=nonstopmode -output-directory "$staging" "$authPath" *> $null
}

Write-Host "  Staged submission content:" -ForegroundColor Cyan
foreach ($f in @($coverPath, $coverPdf, $highPath, $authPath, $authPdf)) {
    if (Test-Path $f) { Write-Host "    OK   $f" -ForegroundColor Green }
    else { Write-Host "    MISS $f" -ForegroundColor Yellow }
}
Write-Host "  Highlight lengths:" -ForegroundColor Cyan
Get-Content -LiteralPath $highPath -Encoding UTF8 | ForEach-Object {
    $color = if ($_.Length -le 85) { "Green" } else { "Yellow" }
    Write-Host ("    {0,2}  {1}" -f $_.Length, $_) -ForegroundColor $color
}
