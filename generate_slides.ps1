# generate_slides.ps1  --  Generate Beamer slides from a paper's .tex source
#
# Usage:
#   generate_slides.ps1 -Project Pub_MyPaper_TBA
#   helpi 19 Pub_MyPaper_TBA
#
param(
    [string]$Project = ""
)

$aiRoot  = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto"
$pubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"

if (!$Project) { $Project = Read-Host "  Project name" }
$projRoot   = Join-Path $pubRoot $Project
$overleafDir = Join-Path $projRoot "Overleaf_source"

if (!(Test-Path $overleafDir)) {
    Write-Host "ERR | Overleaf_source not found: $overleafDir" -ForegroundColor Red
    return
}

# ── Safety net: pull from Overleaf first ──────────────────────────
Write-Host ""
Write-Host "  [1/4] Pulling from Overleaf to avoid overwriting manual edits..." -ForegroundColor Cyan
Push-Location $overleafDir
$pullResult = git pull 2>&1
Write-Host "  $pullResult" -ForegroundColor DarkGray
Pop-Location

# ── Find main .tex file ───────────────────────────────────────────
Write-Host "  [2/4] Locating main .tex file..." -ForegroundColor Cyan
$texFiles = Get-ChildItem $overleafDir -Filter "*.tex" |
    Where-Object { $_.Name -notmatch "^(slides|response|Response)" } |
    Sort-Object LastWriteTime -Descending

$mainTex = ""
if ($texFiles.Count -eq 0) {
    Write-Host "ERR | No .tex files found in $overleafDir" -ForegroundColor Red
    return
} elseif ($texFiles.Count -eq 1) {
    $mainTex = $texFiles[0].Name
} else {
    $named = $texFiles | Where-Object { $_.Name -eq "main.tex" }
    if ($named) {
        $mainTex = "main.tex"
    } else {
        Write-Host ""
        Write-Host "  Multiple .tex files found -- pick one:" -ForegroundColor Yellow
        for ($i = 0; $i -lt [Math]::Min($texFiles.Count, 8); $i++) {
            Write-Host ("  [{0}] {1}" -f ($i+1), $texFiles[$i].Name)
        }
        $pick = Read-Host "  Number"
        if ($pick -match "^\d+$" -and [int]$pick -ge 1 -and [int]$pick -le $texFiles.Count) {
            $mainTex = $texFiles[[int]$pick - 1].Name
        } else {
            Write-Host "ERR | Invalid selection." -ForegroundColor Red
            return
        }
    }
}
Write-Host "  Using: $mainTex" -ForegroundColor DarkGray

# ── Controls ──────────────────────────────────────────────────────
Write-Host "  [3/4] Slide controls..." -ForegroundColor Cyan
Write-Host ""

Write-Host "  Duration:" -ForegroundColor White
Write-Host "    [1] 12 min  (~12 slides -- conference lightning)"
Write-Host "    [2] 30 min  (~25 slides -- standard conference talk)"
Write-Host "    [3] 45 min  (~35 slides -- seminar / research group)"
$durPick = (Read-Host "  Pick [1-3]  (default 2)").Trim()
switch ($durPick) {
    "1" { $duration = "12 minutes"; $slides = "12" }
    "3" { $duration = "45 minutes"; $slides = "35" }
    default { $duration = "30 minutes"; $slides = "25" }
}

Write-Host ""
Write-Host "  Depth:" -ForegroundColor White
Write-Host "    [1] overview   -- story arc + key result only"
Write-Host "    [2] standard   -- methods + results + robustness  (default)"
Write-Host "    [3] deep-dive  -- all details, backup slides, open questions"
$depthPick = (Read-Host "  Pick [1-3]  (default 2)").Trim()
switch ($depthPick) {
    "1" { $depth = "overview" }
    "3" { $depth = "deep-dive" }
    default { $depth = "standard" }
}

Write-Host ""
Write-Host "  Audience:" -ForegroundColor White
Write-Host "    [1] conference      -- assume field knowledge, tight narrative"
Write-Host "    [2] research-group  -- open on methods, encourage discussion  (default)"
Write-Host "    [3] non-specialist  -- explain from scratch, focus on implications"
$audPick = (Read-Host "  Pick [1-3]  (default 2)").Trim()
switch ($audPick) {
    "1" { $audience = "conference" }
    "3" { $audience = "non-specialist" }
    default { $audience = "research-group" }
}

Write-Host ""
Write-Host "  Emphasis:" -ForegroundColor White
Write-Host "    [1] balanced        -- follow paper structure  (default)"
Write-Host "    [2] methods-heavy   -- expand methods, data, identification"
Write-Host "    [3] results-heavy   -- compress methods, lead with findings"
$empPick = (Read-Host "  Pick [1-3]  (default 1)").Trim()
switch ($empPick) {
    "2" { $emphasis = "methods-heavy" }
    "3" { $emphasis = "results-heavy" }
    default { $emphasis = "balanced" }
}

# ── Build and run prompt ──────────────────────────────────────────
Write-Host ""
Write-Host "  [4/4] Generating slides via Claude..." -ForegroundColor Cyan
Write-Host "  Settings: $duration | depth=$depth | audience=$audience | emphasis=$emphasis" -ForegroundColor DarkGray
Write-Host ""

$promptTemplate = Get-Content (Join-Path $aiRoot "prompts\generate_slides.md") -Raw -Encoding UTF8
$prompt = $promptTemplate `
    -replace '\$DURATION', $duration `
    -replace '\$SLIDES',   $slides `
    -replace '\$DEPTH',    $depth `
    -replace '\$AUDIENCE', $audience `
    -replace '\$EMPHASIS', $emphasis `
    -replace '\$MAINFILE', $mainTex

Push-Location $projRoot
& claude -p $prompt
Pop-Location

# ── Confirm output and offer push ────────────────────────────────
$slidesFile = Join-Path $overleafDir "slides_main.tex"
if (!(Test-Path $slidesFile)) {
    Write-Host "WARN | slides_main.tex was not created. Check Claude output above." -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "  slides_main.tex written." -ForegroundColor Green
Write-Host ""
Write-Host "  Push to Overleaf now? [Y] yes  [any other key] skip" -ForegroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""
if ($key.Character -in @('y','Y')) {
    Push-Location $overleafDir
    git add slides_main.tex
    git commit -m "slides: regenerate ($depth, $audience, $duration)"
    git push
    Pop-Location
    Write-Host "  Pushed to Overleaf." -ForegroundColor Green
} else {
    Write-Host "  Skipped push. Run helpi 4 $Project when ready." -ForegroundColor DarkGray
}
Write-Host ""
