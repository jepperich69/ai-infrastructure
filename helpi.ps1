# helpi.ps1  --  Research infrastructure command reference
#
# Usage:
#   helpi                              show menu (auto-detects project from CWD)
#   helpi 3                            run command 3 (uses detected project or prompts)
#   helpi 3 Pub_AssesTiming_Raoul_TBA  run command 3 for a specific project
#   helpi compi                        partial-name match -> runs "Compile LaTeX + open PDF"
#   helpi compi "" main.tex            partial-name match with explicit .tex file
#
param(
    [string]$Cmd     = "",
    [string]$Project = "",
    [string]$TexFile = ""
)

$aiRoot  = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto"
$pubRoot = "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer"
$vscode  = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"

# ── Auto-detect project from current working directory ─────────────
function Get-ProjectFromCwd {
    $cwd      = (Get-Location).Path
    $segments = $cwd -split '[\\\/]'
    # Match known project prefixes in any path segment
    $match = $segments | Where-Object {
        $_ -match '^(Pub_|Pro_|PhD_|CHARGO|42180|DFF|Reagent|BeamerPres|hEART|IATBR|Cycling|Discrete|EV|Paulsen|Presentation|Aalborg|Bicycle|Slides)'
    } | Select-Object -First 1
    if ($match) { return $match } else { return "" }
}

# ── Command definitions ────────────────────────────────────────────
$commands = @(
    [PSCustomObject]@{ N=1;  NeedsProject=$false; Tag="AUTO 4h"; Name="Pull all projects from Overleaf";        Example="sync_all.ps1" },
    [PSCustomObject]@{ N=2;  NeedsProject=$true;  Tag="MANUAL";  Name="Push local edits to Overleaf";           Example="push_to_overleaf.ps1 -Project XXX" },
    [PSCustomObject]@{ N=3;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile LaTeX + open PDF";               Example="compile_latex.ps1 -Project XXX" },
    [PSCustomObject]@{ N=4;  NeedsProject=$true;  Tag="MANUAL";  Name="Close session (log + handover)";         Example="claude -p close.md  in XXX" },
    [PSCustomObject]@{ N=5;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile handover package from AI log";   Example="generate_handover.ps1 -Project XXX" },
    [PSCustomObject]@{ N=6;  NeedsProject=$true;  Tag="MANUAL";  Name="Open handover in browser";               Example='Start-Process "...\XXX\_handover.html"' },
    [PSCustomObject]@{ N=7;  NeedsProject=$true;  Tag="ONCE";    Name="Init code/ git repo";                    Example="init_project_git.ps1 -Project XXX" },
    [PSCustomObject]@{ N=8;  NeedsProject=$false; Tag="INFO";    Name="Open infrastructure guide";              Example="Start-Process infrastructure.html" },
    [PSCustomObject]@{ N=9;  NeedsProject=$true;  Tag="ONCE";    Name="Create new project";                     Example="new_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=10; NeedsProject=$true;  Tag="MANUAL";  Name="Pull one project from Overleaf";         Example="sync_one.ps1 -Project XXX" },
    [PSCustomObject]@{ N=11; NeedsProject=$false; Tag="INFO";    Name="Project status dashboard";               Example="status.ps1" },
    [PSCustomObject]@{ N=12; NeedsProject=$true;  Tag="MANUAL";  Name="Compile + open project (VS Code + PDF)"; Example="open_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=13; NeedsProject=$true;  Tag="MANUAL";  Name="Rollback last N code commits";           Example="rollback.ps1 -Project XXX -N 1" },
    [PSCustomObject]@{ N=14; NeedsProject=$true;  Tag="MANUAL";  Name="Snapshot Overleaf source (git tag)";      Example="snapshot.ps1 -Project XXX [-Tag V2]" },
    [PSCustomObject]@{ N=15; NeedsProject=$false; Tag="INFO";    Name="Open project network graph";              Example="network.ps1" },
    [PSCustomObject]@{ N=16; NeedsProject=$false; Tag="MANUAL";  Name="Generate docs (summary + full HTML/PDF)";  Example="generate_docs.ps1" },
    [PSCustomObject]@{ N=17; NeedsProject=$true;  Tag="MANUAL";  Name="Build submission package";                  Example="submit.ps1 -Project XXX" },
    [PSCustomObject]@{ N=18; NeedsProject=$true;  Tag="MANUAL";  Name="Reviewer response loop";                    Example="claude -p respond.md [R1/R2] in XXX" },
    [PSCustomObject]@{ N=19; NeedsProject=$false; Tag="ONCE";    Name="Register auto-handover task (every 5 min)"; Example="auto_handover.ps1 --register" }
)

# ── Show menu (condensed: one line per command) ────────────────────
function Show-Menu {
    param([string]$forProject = "")
    $label     = if ($forProject) { $forProject } else { "XXX" }
    $detected  = $forProject -ne "" -and $forProject -ne "XXX"

    Write-Host ""
    Write-Host "  Research Infrastructure  |  helpi <N> [Project]" -ForegroundColor Cyan
    if ($detected) {
        Write-Host "  Detected project: $forProject" -ForegroundColor Yellow
    }
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    foreach ($c in $commands) {
        $ex      = $c.Example -replace "XXX", $label
        $tagCol  = switch ($c.Tag) { "AUTO 4h" {"DarkGreen"} "ONCE" {"DarkYellow"} "INFO" {"DarkCyan"} default {"DarkGray"} }
        $num     = ("[{0,2}]" -f $c.N)
        $namepad = $c.Name.PadRight(42)
        Write-Host -NoNewline "  $num " -ForegroundColor White
        Write-Host -NoNewline "$namepad" -ForegroundColor White
        Write-Host -NoNewline (" [{0,-8}]  " -f $c.Tag) -ForegroundColor $tagCol
        Write-Host $ex -ForegroundColor DarkGray
    }
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Preview string for a command (shown before execution) ─────────
function Get-CommandPreview {
    param([int]$n, [string]$proj, [string]$texFile = "")
    switch ($n) {
        1  { "sync_all.ps1" }
        2  { "push_to_overleaf.ps1 -Project $proj" }
        3  { if ($texFile) { "compile_latex.ps1 -Project $proj -TexFile $texFile" }
             else          { "compile_latex.ps1 -Project $proj" } }
        4  { "claude -p ~/.claude/commands/close.md  (in $proj root)" }
        5  { "generate_handover.ps1 -Project $proj" }
        6  { "Start-Process `"$pubRoot\$proj\_handover.html`"" }
        7  { "init_project_git.ps1 -Project $proj" }
        8  { "Start-Process `"$aiRoot\infrastructure.html`"" }
        9  { "new_project.ps1 -Project $proj" }
        10 { "sync_one.ps1 -Project $proj" }
        11 { "status.ps1" }
        12 { "open_project.ps1 -Project $proj" }
        13 { "rollback.ps1 -Project $proj -N 1" }
        14 { "snapshot.ps1 -Project $proj" }
        15 { "network.ps1" }
        16 { "generate_docs.ps1" }
        17 { "submit.ps1 -Project $proj" }
        18 { "claude -p prompts/respond.md  (round: R1/R2/...)" }
    }
}

# ── Execute a command ─────────────────────────────────────────────
function Invoke-Command-N {
    param([int]$n, [string]$proj, [string]$texFile = "")

    $c = $commands | Where-Object { $_.N -eq $n }
    if (!$c) { Write-Host "ERR | Unknown command: $n" -ForegroundColor Red; return }

    if ($c.NeedsProject -and !$proj) {
        $proj = Read-Host "  Project name"
    }

    # ── Preview + confirm ──────────────────────────────────────────
    $preview = Get-CommandPreview -n $n -proj $proj -texFile $texFile
    Write-Host ""
    Write-Host "  [$n] $($c.Name)$(if ($proj) { "  ->  $proj" })" -ForegroundColor Cyan
    Write-Host "  $preview" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [Enter] run  |  [any other key] cancel  (press Up to edit at prompt)" -ForegroundColor DarkGray

    # Pre-load preview into history so Up arrow retrieves it for editing
    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($preview)

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
    if ($key.VirtualKeyCode -ne 13) { return }  # 13 = Enter

    switch ($n) {
        1  { & "$aiRoot\sync_all.ps1" }
        2  { & "$aiRoot\push_to_overleaf.ps1" -Project $proj }
        3  {
               if ($texFile) {
                   & "$aiRoot\compile_latex.ps1" -Project $proj -TexFile $texFile
               } else {
                   & "$aiRoot\compile_latex.ps1" -Project $proj
               }
           }
        4  {
               $projRoot      = Join-Path $pubRoot $proj
               $closePromptPath = Join-Path $env:USERPROFILE ".claude\commands\close.md"
               if (!(Test-Path $closePromptPath)) {
                   Write-Host "ERR  | close.md not found: $closePromptPath" -ForegroundColor Red; return
               }
               $closePrompt = Get-Content $closePromptPath -Raw -Encoding UTF8
               Push-Location $projRoot
               & claude -p $closePrompt
               Pop-Location
           }
        5  { & "$aiRoot\generate_handover.ps1" -Project $proj }
        6  {
               $html = "$pubRoot\$proj\_handover.html"
               if (!(Test-Path $html)) {
                   Write-Host "  Generating handover first..." -ForegroundColor Yellow
                   & "$aiRoot\generate_handover.ps1" -Project $proj
               }
               Start-Process $html
           }
        7  { & "$aiRoot\init_project_git.ps1" -Project $proj }
        8  { Start-Process "$aiRoot\infrastructure.html" }
        9  { & "$aiRoot\new_project.ps1"      -Project $proj }
        10 { & "$aiRoot\sync_one.ps1"         -Project $proj }
        11 { & "$aiRoot\status.ps1" }
        12 { & "$aiRoot\open_project.ps1"     -Project $proj }
        13 {
               $rollN = 1
               $input = Read-Host "  Commits to roll back? (default 1)"
               if ($input -match "^\d+$") { $rollN = [int]$input }
               & "$aiRoot\rollback.ps1" -Project $proj -N $rollN
           }
        14 {
               $tag = Read-Host "  Version label? (e.g. V2, V2-before-submission; leave blank to auto)"
               if ($tag) { & "$aiRoot\snapshot.ps1" -Project $proj -Tag $tag }
               else      { & "$aiRoot\snapshot.ps1" -Project $proj }
           }
        15 { & "$aiRoot\network.ps1" }
        16 { & "$aiRoot\generate_docs.ps1" }
        18 {
               $projRoot   = Join-Path $pubRoot $proj
               $round = Read-Host "  Round? (e.g. R1, R2)"
               if (!$round) { $round = "R1" }
               $draft = Read-Host "  Draft file? (leave blank for clean start)"
               $arg = if ($draft) { "$round --draft $draft" } else { $round }
               $promptFile = Join-Path $aiRoot "prompts\respond.md"
               $promptText = Get-Content $promptFile -Raw -Encoding UTF8
               $promptText = $promptText -replace '\$ARGUMENTS', $arg
               Push-Location $projRoot
               & claude -p $promptText
               Pop-Location
           }
        19 { & "$aiRoot\auto_handover.ps1" --register }
        17 {
               $projRoot   = Join-Path $pubRoot $proj
               $stagingDir = Join-Path $projRoot "_submit_staging"
               $hasCover   = Test-Path (Join-Path $stagingDir "cover_letter.pdf")

               if (!$hasCover) {
                   Write-Host ""
                   Write-Host "  No staged AI content found -- generating via Claude..." -ForegroundColor Cyan
                   $promptFile = Join-Path $aiRoot "prompts\submit_stage_ai.md"
                   $promptText = Get-Content $promptFile -Raw -Encoding UTF8
                   Push-Location $projRoot
                   & claude -p $promptText
                   Pop-Location
               } else {
                   Write-Host "  Staged AI content found -- skipping Claude generation." -ForegroundColor DarkGray
               }

               & "$aiRoot\submit.ps1" -Project $proj
           }
    }
}

# ── Entry point ───────────────────────────────────────────────────
if (!$Project) { $Project = Get-ProjectFromCwd }

if (-not $Cmd) {
    Show-Menu -forProject $Project
} elseif ($Cmd -match "^\d+$") {
    # Numeric command
    $n = [int]$Cmd
    if ($n -lt 1 -or $n -gt ($commands | Measure-Object).Count) {
        Write-Host "ERR | Valid commands are 1-$($commands.Count)" -ForegroundColor Red
        Show-Menu -forProject $Project
    } else {
        Invoke-Command-N -n $n -proj $Project -texFile $TexFile
    }
} else {
    # Partial name match ($matches is reserved in PS; use $found instead)
    $fragment = $Cmd.ToLower()
    $found    = @($commands | Where-Object { $_.Name.ToLower() -like "$fragment*" })

    if ($found.Count -eq 0) {
        Write-Host "ERR | No command matches '$Cmd'" -ForegroundColor Red
        Show-Menu -forProject $Project
    } elseif ($found.Count -eq 1) {
        $m = $found[0]
        Write-Host "  Matched: [$($m.N)] $($m.Name)" -ForegroundColor Yellow
        Invoke-Command-N -n $m.N -proj $Project -texFile $TexFile
    } else {
        Write-Host ""
        Write-Host "  '$Cmd' matches multiple commands:" -ForegroundColor Yellow
        foreach ($m in $found) {
            Write-Host ("    [{0,2}]  {1}" -f $m.N, $m.Name) -ForegroundColor White
        }
        Write-Host ""
    }
}
