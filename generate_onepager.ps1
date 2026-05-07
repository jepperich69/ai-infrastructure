# generate_onepager.ps1  --  Boil a paper down to a technical one-pager + supplement
#
# Usage:
#   generate_onepager.ps1 -Project Pub_MyPaper_TBA
#   generate_onepager.ps1 -Project Pub_MyPaper_TBA -TexFile main.tex   # skip picker
#   generate_onepager.ps1 -Project Pub_MyPaper_TBA -Agent codex        # shell override
#   helpi 24 Pub_MyPaper_TBA
#   helpi 24 Pub_MyPaper_TBA main.tex                                   # skip picker
#
# Output:
#   Overleaf_source/technical_onepager.tex   (one A4 page, fn{N} markers)
#   Overleaf_source/supplement_onepager.tex  (one A4 page, compiled notes 1-N)
#
param(
    [string]$Project = "",
    [string]$TexFile = "",
    [ValidateSet("auto", "claude", "codex")]
    [string]$Agent = "auto"
)

. "$PSScriptRoot\config.ps1"

function Get-ParentProcessText {
    $parts = New-Object System.Collections.Generic.List[string]
    try {
        $pidNow = $PID
        for ($i = 0; $i -lt 8 -and $pidNow; $i++) {
            $p = Get-CimInstance Win32_Process -Filter "ProcessId=$pidNow" -ErrorAction Stop
            if (!$p) { break }
            $parts.Add("$($p.Name) $($p.CommandLine)")
            $pidNow = $p.ParentProcessId
        }
    } catch {
        # Process-tree detection is best effort only.
    }
    return ($parts -join "`n")
}

function Resolve-OnePagerAgent([string]$requested) {
    if ($requested -and $requested -ne "auto") { return $requested }

    if ($env:CODEX_THREAD_ID -or $env:CODEX_MANAGED_BY_NPM) { return "codex" }
    if ($env:CLAUDECODE -or $env:CLAUDE_CODE -or $env:ANTHROPIC_CLAUDE_CODE) { return "claude" }

    $processText = Get-ParentProcessText
    if ($processText -match '(?i)\bcodex(\.cmd|\.exe)?\b') { return "codex" }
    if ($processText -match '(?i)\bclaude(\.cmd|\.exe)?\b') { return "claude" }

    return "claude"
}

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

# -- Find main .tex file ------------------------------------------------------
Write-Host "  [2/3] Locating main manuscript..." -ForegroundColor Cyan

$allTexFiles = Get-ChildItem $overleafDir -Filter "*.tex" |
    Where-Object { $_.Name -notmatch "(?i)^(slides|response|technical_onepager|supplement_onepager|tab_)" }

# Prefer manuscript-style main files; generated tables and response files should not be
# offered as source manuscripts when main*.tex files are present.
$texFiles = $allTexFiles |
    Where-Object { $_.Name -match "(?i)^main.*\.tex$" } |
    Sort-Object LastWriteTime -Descending

if ($texFiles.Count -eq 0) {
    $texFiles = $allTexFiles | Sort-Object LastWriteTime -Descending
}

if ($texFiles.Count -eq 0) {
    Write-Host "ERR | No .tex files found in $overleafDir" -ForegroundColor Red
    return
}

$mainTex = ""

if ($TexFile) {
    # Caller specified the file directly (e.g. helpi 24 proj main.tex).
    $mainTex = $TexFile
} elseif ($texFiles.Count -eq 1) {
    $mainTex = $texFiles[0].Name
    Write-Host "  Single candidate found: $mainTex" -ForegroundColor DarkGray
} elseif ([System.Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    # Interactive terminal -- show picker.
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
} else {
    # Non-interactive agent or piped input. Do not guess when several manuscripts exist.
    Write-Host "ERR | Multiple candidate .tex files found. Specify the source manuscript explicitly:" -ForegroundColor Red
    foreach ($f in $texFiles) {
        Write-Host ("      - {0}" -f $f.Name) -ForegroundColor DarkGray
    }
    Write-Host "      Example: helpi 24 $Project main_R1.tex" -ForegroundColor Yellow
    return
}

Write-Host "  Using: $mainTex" -ForegroundColor DarkGray

# -- Generate -----------------------------------------------------------------
$resolvedAgent = Resolve-OnePagerAgent $Agent
Write-Host ""
Write-Host "  [3/3] Generating one-pager via $resolvedAgent..." -ForegroundColor Cyan
Write-Host ""

$promptTemplate = Get-Content (Join-Path $aiRoot "prompts\generate_onepager.md") -Raw -Encoding UTF8
$prompt = $promptTemplate -replace '\$MAINFILE', $mainTex

Push-Location $projRoot
if ($resolvedAgent -eq "codex") {
    $promptFile = Join-Path ([System.IO.Path]::GetTempPath()) ("onepager_prompt_{0}.md" -f ([guid]::NewGuid().ToString("N")))
    Set-Content -Path $promptFile -Value $prompt -Encoding UTF8
    try {
        Get-Content -LiteralPath $promptFile -Raw -Encoding UTF8 |
            & codex.cmd exec -C $projRoot --add-dir $projRoot --sandbox workspace-write --skip-git-repo-check --ephemeral -
    } finally {
        if (Test-Path $promptFile) { Remove-Item -LiteralPath $promptFile -Force }
    }
} else {
    & claude -p $prompt
}
Pop-Location

# -- Confirm output -----------------------------------------------------------
$outMain = Join-Path $overleafDir "technical_onepager.tex"
$outSupp = Join-Path $overleafDir "supplement_onepager.tex"
$missing = @()
if (!(Test-Path $outMain)) { $missing += "technical_onepager.tex" }
if (!(Test-Path $outSupp)) { $missing += "supplement_onepager.tex" }

if ($missing.Count -gt 0) {
    Write-Host ""
    foreach ($m in $missing) {
        Write-Host "WARN | $m was not created. Check $resolvedAgent output above." -ForegroundColor Yellow
    }
    if ($missing.Count -eq 2) { return }
}

Write-Host ""
if (Test-Path $outMain) { Write-Host "  OK | technical_onepager.tex written."  -ForegroundColor Green }
if (Test-Path $outSupp) { Write-Host "  OK | supplement_onepager.tex written." -ForegroundColor Green }
Write-Host ""
Write-Host "  Push to Overleaf now? [Y] yes  [any other key] skip" -ForegroundColor White
$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""
if ($key.Character -in @('y', 'Y')) {
    Push-Location $overleafDir
    $filesToAdd = @("technical_onepager.tex", "supplement_onepager.tex") |
        Where-Object { Test-Path (Join-Path $overleafDir $_) }
    foreach ($f in $filesToAdd) { git add $f }
    git commit -m "onepager: generate from $mainTex"
    git push
    Pop-Location
    Write-Host "  Pushed to Overleaf." -ForegroundColor Green
} else {
    Write-Host "  Skipped. Run helpi 4 $Project when ready." -ForegroundColor DarkGray
}
Write-Host ""
