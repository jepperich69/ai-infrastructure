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
    [PSCustomObject]@{ N=4;  NeedsProject=$true;  Tag="MANUAL";  Name="Log + handover";                        Example="claude -p close.md  in XXX" },
    [PSCustomObject]@{ N=5;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile handover package from AI log";   Example="generate_handover.ps1 -Project XXX" },
    [PSCustomObject]@{ N=6;  NeedsProject=$true;  Tag="MANUAL";  Name="Open handover in browser";               Example='Start-Process "...\XXX\_handover.html"' },
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

# ── Contextual help for a single command ─────────────────────────
function Show-CommandHelp {
    param([int]$n, [string]$proj)
    $p = if ($proj) { $proj } else { "Pub_YourProject" }
    $lines = switch ($n) {
        1  { @(
            "Pull all projects from Overleaf",
            "Runs 'git pull' in every Overleaf_source/ folder registered in projects.json.",
            "Safe to run anytime - only fast-forwards if there are no local edits.",
            "",
            "When to use: start of day, or before opening a project you haven't touched recently.",
            "",
            "Example:",
            "  helpi 1"
        )}
        2  { @(
            "Push local edits to Overleaf",
            "Pushes changes in Overleaf_source/ back to the Overleaf git remote.",
            "Use after editing .tex files locally that you want reflected on Overleaf.",
            "",
            "When to use: after editing manuscript files locally (e.g. via VS Code).",
            "",
            "Example:",
            "  helpi 2 $p"
        )}
        3  { @(
            "Compile LaTeX + open PDF",
            "Runs latexmk on the chosen .tex file (with -g to force recompile) and opens",
            "the resulting PDF. Prompts you to pick a .tex file if more than one exists.",
            "",
            "When to use: standalone compile without opening the full VS Code workspace.",
            "",
            "Example:",
            "  helpi 3 $p"
        )}
        4  { @(
            "Log + handover",
            "Runs claude -p with the /close prompt in the project root. Claude writes a",
            "session block to _ai_log.md, updates .claude/CLAUDE.md, and regenerates the",
            "handover HTML + AGENTS.md. Equivalent to running /close inside Claude.",
            "",
            "When to use: end of a working session, or mid-session checkpoint.",
            "",
            "Example:",
            "  helpi 4 $p"
        )}
        5  { @(
            "Compile handover package from AI log",
            "Reads _ai_log.md and regenerates _handover.html, _handover.json, and AGENTS.md.",
            "No Claude call - pure PowerShell. Also what the auto-handover timer runs.",
            "",
            "When to use: after manually editing _ai_log.md, or to refresh the handover",
            "without running a full /close.",
            "",
            "Example:",
            "  helpi 5 $p"
        )}
        6  { @(
            "Open handover in browser",
            "Opens _handover.html for the project. Generates it first if it doesn't exist.",
            "",
            "When to use: to review session history before starting work, or to hand off",
            "context to another agent.",
            "",
            "Example:",
            "  helpi 6 $p"
        )}
        8  { @(
            "Open infrastructure guide",
            "Opens infrastructure.html in the default browser - the full reference guide",
            "for this research infrastructure setup.",
            "",
            "Example:",
            "  helpi 8"
        )}
        9  { @(
            "Create new project",
            "Scaffolds a complete project folder: code/, code/data/, Literature/,",
            "Overleaf_source/, _ai_log.md, .claude/settings.json, .claude/CLAUDE.md.",
            "Optionally clones an Overleaf git URL into Overleaf_source/.",
            "",
            "When to use: starting a new paper. Run once per project.",
            "",
            "Example:",
            "  helpi 9 Pub_NewPaper_TBA",
            "  helpi 9 Pub_NewPaper_TBA https://git.overleaf.com/abc123"
        )}
        10 { @(
            "Pull one project from Overleaf",
            "Runs 'git pull' in a single project's Overleaf_source/ folder.",
            "Faster than helpi 1 when you only need one project up to date.",
            "",
            "Example:",
            "  helpi 10 $p"
        )}
        11 { @(
            "Project status dashboard",
            "Shows a summary table of all projects: last sync, last session, open issues.",
            "No project argument needed.",
            "",
            "Example:",
            "  helpi 11"
        )}
        12 { @(
            "Compile + open project (VS Code + PDF)",
            "The main 'start working' command. Picks a .tex file, compiles it, opens VS Code",
            "on the chosen file, opens File Explorer on the project root, and opens the",
            "freshly compiled PDF. Also auto-inits code/ git repo if missing.",
            "",
            "When to use: beginning of a working session on a project.",
            "",
            "Example:",
            "  helpi 12 $p"
        )}
        13 { @(
            "Rollback last N code commits",
            "Runs 'git reset --hard HEAD~N' in the project's code/ repo.",
            "Prompts for N (default 1). PERMANENT - use with care.",
            "",
            "When to use: to undo recent code changes that broke something.",
            "",
            "Example:",
            "  helpi 13 $p   # then enter N when prompted"
        )}
        14 { @(
            "Snapshot Overleaf source (git tag)",
            "Creates an annotated git tag (snapshot-v1, snapshot-v2, ...) on the current",
            "HEAD of Overleaf_source/. Captures the full manuscript state: .tex, .bib,",
            "figures, style files. Aborts if there are uncommitted changes.",
            "",
            "When to use: before submitting, before a major revision, or at any milestone.",
            "Lets you diff or restore any file back to that exact state later.",
            "",
            "Example:",
            "  helpi 14 $p              # auto-increments version",
            "  helpi 14 $p V2-before-R1 # custom label"
        )}
        15 { @(
            "Open project network graph",
            "Generates network.html showing all projects with feeder links as directed",
            "arrows. Connected projects are grouped into colour-coded clusters with convex",
            "hull shading. Node colour = recency of last session. Drag, zoom, hover.",
            "",
            "Example:",
            "  helpi 15"
        )}
        16 { @(
            "Generate docs (summary + full HTML/PDF)",
            "Runs generate_docs.ps1 to produce four files from infrastructure.html:",
            "infrastructure_summary.html/.pdf (1-2 pager) and infrastructure_full.html/.pdf.",
            "",
            "When to use: after editing infrastructure.html and wanting fresh PDFs.",
            "",
            "Example:",
            "  helpi 16"
        )}
        17 { @(
            "Build submission package",
            "Assembles a complete journal submission folder under _submissions/YYYY-MM-DD_Journal/.",
            "Steps: (1) compile manuscript, (2) extract front page, (3) inline bibliography,",
            "(4) submission zip, (5) blind manuscript + zip, (6) latexdiff vs previous version,",
            "(7) copy AI-generated cover letter / highlights / author statement.",
            "If no staged AI content exists, calls Claude first to generate it.",
            "",
            "When to use: ready to submit or resubmit a paper.",
            "",
            "Example:",
            "  helpi 17 $p"
        )}
        18 { @(
            "Reviewer response loop",
            "Runs the /respond skill via claude -p in the project root. Guides Claude through",
            "drafting a structured reviewer response letter for a given round (R1, R2, ...).",
            "",
            "When to use: after receiving reviewer comments, to draft the response letter.",
            "",
            "Example:",
            "  helpi 18 $p   # then enter round (R1/R2) when prompted"
        )}
        19 { @(
            "Register auto-handover task (every 5 min)",
            "Installs a Windows scheduled task that runs auto_handover.ps1 every 5 minutes.",
            "The task finds the most recently active project and regenerates its handover",
            "HTML + AGENTS.md - but only if _ai_log.md is newer than _handover.html.",
            "Run once. To remove: auto_handover.ps1 --unregister",
            "",
            "Example:",
            "  helpi 19"
        )}
        default { @("No help available for command $n.") }
    }

    $c = $commands | Where-Object { $_.N -eq $n }
    $cName = if ($c) { $c.Name } else { "Unknown" }
    Write-Host ""
    Write-Host ("  [{0}] {1}" -f $n, $cName) -ForegroundColor Cyan
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    foreach ($l in $lines) { Write-Host "  $l" }
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Tip: helpi $n $p   to run" -ForegroundColor DarkGray
    Write-Host ""
}

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

# Help mode: helpi 4 ?
if ($Project -in @('?','help')) {
    if ($Cmd -match "^\d+$") {
        Show-CommandHelp -n ([int]$Cmd) -proj (Get-ProjectFromCwd)
    } else {
        Write-Host "  Usage: helpi <N> --help" -ForegroundColor Yellow
    }
    return
}

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
