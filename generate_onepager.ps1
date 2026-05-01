# generate_onepager.ps1  --  Boil a paper down to a technical one-pager
#
# Usage:
#   generate_onepager.ps1 -Project Pub_MyPaper_TBA
#   helpi 24 Pub_MyPaper_TBA
#
# Output:
#   Overleaf_source/technical_onepager.tex  (one A4 page, no citations, no figures)
#
param(
    [string]$Project = ""
)

. "$PSScriptRoot\config.ps1"

if (!$Project) { $Project = Read-Host "  Project name" }
$projRoot    = Resolve-ProjectRoot $Project
$overleafDir = Join-Path $projRoot "Overleaf_source"

if (!(Test-Path $overleafDir)) {
    Write-Host "ERR | Overleaf_source not found: $overleafDir" -ForegroundColor Red
    return
}

# -- Pull from Overleaf first -------------------------------------------------
Write-Host ""
Write-Host "  [1/3] Pulling from Overleaf..." -ForegroundColor Cyan
Push-Location $overleafDir
$pullResult = git pull 2>&1
Write-Host "  $pullResult" -ForegroundColor DarkGray
Pop-Location

# -- Find main .tex file (pop-up picker) --------------------------------------
Write-Host "  [2/3] Locating main manuscript..." -ForegroundColor Cyan

$texFiles = Get-ChildItem $overleafDir -Filter "*.tex" |
    Where-Object { $_.Name -notmatch "(?i)^(slides|response|technical_onepager)" } |
    Sort-Object LastWriteTime -Descending

if ($texFiles.Count -eq 0) {
    Write-Host "ERR | No .tex files found in $overleafDir" -ForegroundColor Red
    return
}

# -- Windows Forms picker (always shown) --------------------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form           = New-Object System.Windows.Forms.Form
$form.Text      = "Select source manuscript"
$form.Size      = New-Object System.Drawing.Size(420, 280)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false

$label          = New-Object System.Windows.Forms.Label
$label.Text     = "Which .tex file is the main manuscript?"
$label.Location = New-Object System.Drawing.Point(14, 14)
$label.Size     = New-Object System.Drawing.Size(380, 20)
$form.Controls.Add($label)

$listBox        = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(14, 42)
$listBox.Size   = New-Object System.Drawing.Size(378, 160)
$listBox.Font   = New-Object System.Drawing.Font("Consolas", 9)
foreach ($f in $texFiles) { $listBox.Items.Add($f.Name) | Out-Null }

# Pre-select main.tex if present, otherwise the most-recently-modified file
$defaultIdx = 0
$mainIdx    = $listBox.Items.IndexOf("main.tex")
if ($mainIdx -ge 0) { $defaultIdx = $mainIdx }
$listBox.SelectedIndex = $defaultIdx
$form.Controls.Add($listBox)

$btnOK          = New-Object System.Windows.Forms.Button
$btnOK.Text     = "OK"
$btnOK.Location = New-Object System.Drawing.Point(230, 210)
$btnOK.Size     = New-Object System.Drawing.Size(75, 26)
$btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $btnOK
$form.Controls.Add($btnOK)

$btnCancel      = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Cancel"
$btnCancel.Location = New-Object System.Drawing.Point(317, 210)
$btnCancel.Size = New-Object System.Drawing.Size(75, 26)
$btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $btnCancel
$form.Controls.Add($btnCancel)

$result = $form.ShowDialog()
$form.Dispose()

if ($result -ne [System.Windows.Forms.DialogResult]::OK -or $listBox.SelectedIndex -lt 0) {
    Write-Host "  Cancelled." -ForegroundColor Yellow
    return
}
$mainTex = $listBox.SelectedItem

Write-Host "  Using: $mainTex" -ForegroundColor DarkGray

# -- Generate -----------------------------------------------------------------
Write-Host ""
Write-Host "  [3/3] Generating one-pager via Claude..." -ForegroundColor Cyan
Write-Host ""

$promptTemplate = Get-Content (Join-Path $aiRoot "prompts\generate_onepager.md") -Raw -Encoding UTF8
$prompt = $promptTemplate -replace '\$MAINFILE', $mainTex

Push-Location $projRoot
& claude -p $prompt
Pop-Location

# -- Confirm output -----------------------------------------------------------
$outFile = Join-Path $overleafDir "technical_onepager.tex"
if (!(Test-Path $outFile)) {
    Write-Host ""
    Write-Host "WARN | technical_onepager.tex was not created. Check Claude output above." -ForegroundColor Yellow
    return
}

Write-Host ""
Write-Host "  OK | technical_onepager.tex written." -ForegroundColor Green
Write-Host ""
Write-Host "  Push to Overleaf now? [Y] yes  [any other key] skip" -ForegroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""
if ($key.Character -in @('y', 'Y')) {
    Push-Location $overleafDir
    git add technical_onepager.tex
    git commit -m "onepager: generate from $mainTex"
    git push
    Pop-Location
    Write-Host "  Pushed to Overleaf." -ForegroundColor Green
} else {
    Write-Host "  Skipped. Run helpi 4 $Project when ready." -ForegroundColor DarkGray
}
Write-Host ""
