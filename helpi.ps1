# helpi.ps1  --  Research infrastructure command reference
#
# Usage:
#   helpi                              show menu (auto-detects project from CWD)
#   helpi 5                            run command 5 (uses detected project or prompts)
#   helpi 5 Pub_AssesTiming_Raoul_TBA  run command 5 for a specific project
#   helpi 5 ?                          show help for command 5
#   helpi compi                        partial-name match -> runs "Compile LaTeX + open PDF"
#
param(
    [string]$Cmd     = "",
    [string]$Project = "",
    [string]$TexFile = ""
)

. "$PSScriptRoot\config.ps1"

# ── Auto-detect project from current working directory ─────────────
function Get-ProjectFromCwd {
    $cwd      = (Get-Location).Path
    $segments = $cwd -split '[\\\/]'
    $match = $segments | Where-Object {
        $_ -match '^(Pub_|Pro_|PhD_|AI_auto|CV|CHARGO|42180|DFF|Reagent|BeamerPres|hEART|IATBR|Cycling|Discrete|EV|Paulsen|Presentation|Aalborg|Bicycle|Slides)'
    } | Select-Object -First 1
    if ($match) { return $match } else { return "" }
}

# ── Command definitions ────────────────────────────────────────────
$commands = @(
    [PSCustomObject]@{ N=1;  NeedsProject=$true;  Tag="ONCE";    Name="Create new project";                        Example="new_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=2;  NeedsProject=$false; Tag="AUTO 4h"; Name="Pull all projects from Overleaf";           Example="sync_all.ps1" },
    [PSCustomObject]@{ N=3;  NeedsProject=$true;  Tag="MANUAL";  Name="Pull one project from Overleaf";            Example="sync_one.ps1 -Project XXX" },
    [PSCustomObject]@{ N=4;  NeedsProject=$true;  Tag="MANUAL";  Name="Push local edits to Overleaf";              Example="push_to_overleaf.ps1 -Project XXX" },
    [PSCustomObject]@{ N=5;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile + open project (VS Code + PDF)";    Example="open_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=6;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile LaTeX + open PDF";                  Example="compile_latex.ps1 -Project XXX" },
    [PSCustomObject]@{ N=7;  NeedsProject=$true;  Tag="MANUAL";  Name="Log + handover + open in browser";          Example="claude -p close.md + handover in XXX" },
    [PSCustomObject]@{ N=8;  NeedsProject=$true;  Tag="MANUAL";  Name="Snapshot Overleaf source (git tag)";        Example="snapshot.ps1 -Project XXX [-Tag V2]" },
    [PSCustomObject]@{ N=9;  NeedsProject=$true;  Tag="MANUAL";  Name="Rollback last N code commits";              Example="rollback.ps1 -Project XXX -N 1" },
    [PSCustomObject]@{ N=10; NeedsProject=$true;  Tag="MANUAL";  Name="Build submission package";                  Example="submit.ps1 -Project XXX" },
    [PSCustomObject]@{ N=11; NeedsProject=$true;  Tag="MANUAL";  Name="Reviewer scaffold (.txt -> LaTeX + push)";  Example="respond_scaffold.md in XXX" },
    [PSCustomObject]@{ N=12; NeedsProject=$true;  Tag="MANUAL";  Name="Reviewer draft loop (pull -> draft -> push)";Example="respond_draft.md in XXX" },
    [PSCustomObject]@{ N=13; NeedsProject=$false; Tag="INFO";    Name="Project status dashboard";                  Example="status.ps1" },
    [PSCustomObject]@{ N=14; NeedsProject=$false; Tag="INFO";    Name="Open project network graph";                Example="network.ps1" },
    [PSCustomObject]@{ N=15; NeedsProject=$false; Tag="INFO";    Name="Open infrastructure guide";                 Example="Start-Process infrastructure.html" },
    [PSCustomObject]@{ N=16; NeedsProject=$false; Tag="MANUAL";  Name="Generate docs (summary + full HTML/PDF)";   Example="generate_docs.ps1" },
    [PSCustomObject]@{ N=17; NeedsProject=$false; Tag="INFO";    Name="Claude Code in-session command reference";   Example="(cheatsheet -- no args needed)" },
    [PSCustomObject]@{ N=18; NeedsProject=$false; Tag="MANUAL";  Name="Toggle Claude model-check on/off";            Example="(edits memory -- persists to next session)" },
    [PSCustomObject]@{ N=19; NeedsProject=$true;  Tag="MANUAL";  Name="Generate Beamer slides from paper";            Example="generate_slides.ps1 -Project XXX" },
    [PSCustomObject]@{ N=20; NeedsProject=$false; Tag="ONCE";    Name="Restore infrastructure on replacement machine"; Example="restore.ps1" },
    [PSCustomObject]@{ N=21; NeedsProject=$false; Tag="ONCE";    Name="First-time setup for a new user/colleague";    Example="setup.ps1" },
    [PSCustomObject]@{ N=22; NeedsProject=$true;  Tag="MANUAL";  Name="Compress AI log (trim old sessions)";           Example="compress_log.ps1 -Project XXX" }
)

# ── Contextual help for a single command ──────────────────────────
function Show-CommandHelp {
    param([int]$n, [string]$proj)
    $p = if ($proj) { $proj } else { "Pub_YourProject" }
    $lines = switch ($n) {
        1  { @(
            "Create new project",
            "Scaffolds a complete project folder: code/, code/data/, Literature/,",
            "Overleaf_source/, _ai_log.md, .claude/settings.json, .claude/CLAUDE.md.",
            "Also registers the auto-handover scheduled task if not already set up.",
            "Optionally clones an Overleaf git URL into Overleaf_source/.",
            "",
            "When to use: starting a new paper. Run once per project.",
            "",
            "Example:",
            "  helpi 1 Pub_NewPaper_TBA",
            "  helpi 1 Pub_NewPaper_TBA https://git.overleaf.com/abc123"
        )}
        2  { @(
            "Pull all projects from Overleaf",
            "Runs 'git pull' in every Overleaf_source/ folder registered in projects.json.",
            "Safe to run anytime - only fast-forwards if there are no local edits.",
            "",
            "When to use: start of day, or before opening a project you haven't touched recently.",
            "",
            "Example:",
            "  helpi 2"
        )}
        3  { @(
            "Pull one project from Overleaf",
            "Runs 'git pull' in a single project's Overleaf_source/ folder.",
            "Faster than helpi 2 when you only need one project up to date.",
            "",
            "Example:",
            "  helpi 3 $p"
        )}
        4  { @(
            "Push local edits to Overleaf",
            "Pushes changes in Overleaf_source/ back to the Overleaf git remote.",
            "",
            "When to use: after editing manuscript files locally (e.g. via VS Code).",
            "",
            "Example:",
            "  helpi 4 $p"
        )}
        5  { @(
            "Compile + open project (VS Code + PDF)",
            "The main 'start working' command. Picks a .tex file, compiles it, opens VS Code",
            "on the chosen file, opens File Explorer on the project root, and opens the",
            "freshly compiled PDF. Also auto-inits code/ git repo if missing.",
            "",
            "When to use: beginning of a working session on a project.",
            "",
            "Example:",
            "  helpi 5 $p"
        )}
        6  { @(
            "Compile LaTeX + open PDF",
            "Runs latexmk on the chosen .tex file (with -g to force recompile) and opens",
            "the resulting PDF. Prompts you to pick a .tex file if more than one exists.",
            "",
            "When to use: standalone compile without opening the full VS Code workspace.",
            "",
            "Example:",
            "  helpi 6 $p"
        )}
        7  { @(
            "Log + handover + open in browser",
            "Runs claude -p with the /close prompt: writes session block to _ai_log.md,",
            "updates .claude/CLAUDE.md, regenerates _handover.html + AGENTS.md,",
            "then opens the handover in the browser.",
            "",
            "When to use: end of a working session, or mid-session checkpoint.",
            "",
            "Example:",
            "  helpi 7 $p"
        )}
        8  { @(
            "Snapshot Overleaf source (git tag)",
            "Creates an annotated git tag (snapshot-v1, snapshot-v2, ...) on the current",
            "HEAD of Overleaf_source/. Captures the full manuscript state: .tex, .bib,",
            "figures, style files. Aborts if there are uncommitted changes.",
            "",
            "When to use: before submitting, before a major revision, or at any milestone.",
            "Lets you diff or restore any file back to that exact state later.",
            "",
            "Example:",
            "  helpi 8 $p              # auto-increments version",
            "  helpi 8 $p V2-before-R1 # custom label"
        )}
        9  { @(
            "Rollback last N code commits",
            "Runs 'git reset --hard HEAD~N' in the project's code/ repo.",
            "Prompts for N (default 1). PERMANENT - use with care.",
            "",
            "When to use: to undo recent code changes that broke something.",
            "",
            "Example:",
            "  helpi 9 $p   # then enter N when prompted"
        )}
        10 { @(
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
            "  helpi 10 $p"
        )}
        11 { @(
            "Reviewer scaffold (.txt -> LaTeX + push)",
            "Parses a flat .txt file of reviewer comments, numbers them (R1.1, R2.1, AE.1...),",
            "and generates Response_R1.tex using the standard reviewerbox/responsebox template.",
            "Each comment gets a \TODO{} response slot. Pushes to Overleaf when done.",
            "",
            "Authors then fill in \TODO{} slots in Overleaf:",
            "  \TODO{Simple}         - Claude handles solo in helpi 12",
            "  \TODO{[NOTE] ...}     - Claude follows your guidance",
            "  \TODO{[SKIP]}         - you write manually",
            "",
            "When to use: immediately after receiving reviewer comments.",
            "",
            "Example:",
            "  helpi 11 $p   # then enter round (R1/R2) when prompted"
        )}
        12 { @(
            "Reviewer draft loop (pull -> draft -> push)",
            "Auto-pulls from Overleaf, reads the author-annotated Response_R1.tex,",
            "and drafts a polished academic response for every \TODO{} slot.",
            "Uses the manuscript for context (cites sections, equations, tables).",
            "Skips \TODO{[SKIP]} slots and leaves already-written text untouched.",
            "Pushes the completed draft back to Overleaf when done.",
            "",
            "When to use: after all authors have annotated the scaffold in Overleaf.",
            "",
            "Example:",
            "  helpi 12 $p   # then enter round (R1/R2) when prompted"
        )}
        13 { @(
            "Project status dashboard",
            "Shows a summary table of all projects: last sync, last session, open issues.",
            "",
            "Example:",
            "  helpi 13"
        )}
        14 { @(
            "Open project network graph",
            "Generates network.html showing all projects with feeder links as directed",
            "arrows. Connected projects are grouped into colour-coded clusters with convex",
            "hull shading. Node colour = recency of last session. Drag, zoom, hover.",
            "",
            "Example:",
            "  helpi 14"
        )}
        15 { @(
            "Open infrastructure guide",
            "Opens infrastructure.html in the default browser - the full reference guide",
            "for this research infrastructure setup.",
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
            "Claude Code in-session command reference",
            "Prints a cheatsheet of all slash commands and keyboard shortcuts",
            "available inside a Claude Code session.",
            "",
            "Example:",
            "  helpi 17"
        )}
        19 { @(
            "Generate Beamer slides from paper",
            "Safety-pulls from Overleaf first, then asks four controls:",
            "  Duration:  12 min / 30 min / 45 min",
            "  Depth:     overview / standard / deep-dive",
            "  Audience:  conference / research-group / non-specialist",
            "  Emphasis:  balanced / methods-heavy / results-heavy",
            "Writes slides_main.tex into Overleaf_source/. Offers to push to Overleaf.",
            "Regeneration overwrites slides_main.tex -- safety pull preserves Overleaf edits.",
            "",
            "Presets (skip interactive questions):",
            "  quick    12 min, overview, conference, balanced",
            "           -> helpi 19 $p quick",
            "  seminar  45 min, deep-dive, research-group, methods-heavy",
            "           -> helpi 19 $p seminar",
            "  public   30 min, overview, non-specialist, results-heavy",
            "           -> helpi 19 $p public",
            "",
            "Example (interactive):",
            "  helpi 19 $p"
        )}
        20 { @(
            "Restore infrastructure on a replacement machine",
            "Checks all dependencies and fixes what it can automatically:",
            "  - Claude Code CLI, Git, MiKTeX, VS Code",
            "  - PowerShell profile (helpi function)",
            "  - Scheduled task (auto-sync every 4h)",
            "  - ~/.claude/ folder (CLAUDE.md, commands/)",
            "  - projects.json",
            "Files are assumed intact (OneDrive sync). Only the local machine setup is restored.",
            "",
            "Example:",
            "  helpi 20"
        )}
        21 { @(
            "First-time setup for a new user or colleague",
            "Interactive wizard that configures the infrastructure from scratch:",
            "  1. Ask for publications root folder",
            "  2. Set git user name + email",
            "  3. Detect or prompt for tool paths (VS Code, MiKTeX, Perl)",
            "  4. Write config.ps1 with all paths in one place",
            "  5. Wire helpi into the PowerShell profile",
            "  6. Register the auto-sync scheduled task",
            "",
            "Prerequisites (install manually first):",
            "  Claude Code, Git, MiKTeX, VS Code, Strawberry Perl",
            "  Then run: claude login",
            "",
            "Example:",
            "  helpi 21"
        )}
        18 { @(
            "Toggle Claude model-check on/off",
            "Enables or disables the behavior where Claude assesses each task",
            "and suggests switching to Haiku when appropriate.",
            "Edits the memory file -- takes effect from the next session.",
            "For the current session, just tell Claude 'model check off'.",
            "",
            "Example:",
            "  helpi 18"
        )}
        22 { @(
            "Compress AI log (trim old sessions)",
            "Keeps the last 4 sessions in _ai_log.md verbatim.",
            "Compresses older sessions into one-liners under ## Compressed sessions.",
            "Archives one-liners to _ai_log_archive.md once they exceed 16.",
            "",
            "Runs automatically at /close. Use manually to compress a log on demand.",
            "",
            "Example:",
            "  helpi 22 $p"
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
    $label    = if ($forProject) { $forProject } else { "XXX" }
    $detected = $forProject -ne "" -and $forProject -ne "XXX"

    Write-Host ""
    Write-Host "  Research Infrastructure  |  helpi <N> [Project]  |  helpi <N> ?" -ForegroundColor Cyan
    if ($detected) {
        Write-Host "  Detected project: $forProject" -ForegroundColor Yellow
    }
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    foreach ($c in $commands) {
        $ex      = $c.Example -replace "XXX", $label
        $tagCol  = switch ($c.Tag) { "AUTO 4h" {"DarkGreen"} "ONCE" {"DarkYellow"} "INFO" {"DarkCyan"} default {"DarkGray"} }
        $num     = ("[{0,2}]" -f $c.N)
        $namepad = $c.Name.PadRight(44)
        Write-Host -NoNewline "  $num " -ForegroundColor White
        Write-Host -NoNewline "$namepad" -ForegroundColor White
        Write-Host -NoNewline (" [{0,-8}]  " -f $c.Tag) -ForegroundColor $tagCol
        Write-Host $ex -ForegroundColor DarkGray
    }
    Write-Host "  -----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Preview string for a command (shown before execution) ──────────
function Get-CommandPreview {
    param([int]$n, [string]$proj, [string]$texFile = "")
    switch ($n) {
        1  { "new_project.ps1 -Project $proj" }
        2  { "sync_all.ps1" }
        3  { "sync_one.ps1 -Project $proj" }
        4  { "push_to_overleaf.ps1 -Project $proj" }
        5  { "open_project.ps1 -Project $proj" }
        6  { if ($texFile) { "compile_latex.ps1 -Project $proj -TexFile $texFile" }
             else          { "compile_latex.ps1 -Project $proj" } }
        7  { "claude -p close.md + generate_handover.ps1 + open browser  ($proj)" }
        8  { "snapshot.ps1 -Project $proj" }
        9  { "rollback.ps1 -Project $proj -N 1" }
        10 { "submit.ps1 -Project $proj" }
        11 { "claude -p prompts/respond_scaffold.md  (round: R1/R2/...)" }
        12 { "claude -p prompts/respond_draft.md    (round: R1/R2/...)" }
        13 { "status.ps1" }
        14 { "network.ps1" }
        15 { "Start-Process `"$aiRoot\infrastructure.html`"" }
        16 { "generate_docs.ps1" }
        17 { "(print Claude Code cheatsheet)" }
        18 { "(toggle Claude model-check in memory file)" }
        19 { if ($texFile) { "generate_slides.ps1 -Project $proj -Preset $texFile" }
             else          { "generate_slides.ps1 -Project $proj  (interactive)" } }
        20 { "restore.ps1" }
        21 { "setup.ps1" }
        22 { "compress_log.ps1 -Project $proj" }
    }
}

# ── Execute a command ──────────────────────────────────────────────
function Invoke-Command-N {
    param([int]$n, [string]$proj, [string]$texFile = "")

    $c = $commands | Where-Object { $_.N -eq $n }
    if (!$c) { Write-Host "ERR | Unknown command: $n" -ForegroundColor Red; return }

    if ($c.NeedsProject -and !$proj) {
        $proj = Read-Host "  Project name"
    }

    $preview = Get-CommandPreview -n $n -proj $proj -texFile $texFile
    Write-Host ""
    Write-Host "  [$n] $($c.Name)$(if ($proj) { "  ->  $proj" })" -ForegroundColor Cyan
    Write-Host "  $preview" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  [Enter] run  |  [any other key] cancel  (press Up to edit at prompt)" -ForegroundColor DarkGray

    [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($preview)

    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
    if ($key.VirtualKeyCode -ne 13) { return }

    switch ($n) {
        1  { & "$aiRoot\new_project.ps1" -Project $proj }
        2  { & "$aiRoot\sync_all.ps1" }
        3  { & "$aiRoot\sync_one.ps1" -Project $proj }
        4  { & "$aiRoot\push_to_overleaf.ps1" -Project $proj }
        5  { & "$aiRoot\open_project.ps1" -Project $proj }
        6  {
               if ($texFile) { & "$aiRoot\compile_latex.ps1" -Project $proj -TexFile $texFile }
               else           { & "$aiRoot\compile_latex.ps1" -Project $proj }
           }
        7  {
               $projRoot        = Resolve-ProjectRoot $proj
               $closePromptPath = Join-Path $env:USERPROFILE ".claude\commands\close.md"
               if (!(Test-Path $closePromptPath)) {
                   Write-Host "ERR  | close.md not found: $closePromptPath" -ForegroundColor Red; return
               }
               $closePrompt = Get-Content $closePromptPath -Raw -Encoding UTF8
               Push-Location $projRoot
               & claude -p $closePrompt
               Pop-Location
               & "$aiRoot\generate_handover.ps1" -Project $proj
               $html = Join-Path $projRoot "_handover.html"
               if (Test-Path $html) { Start-Process $html }
           }
        8  {
               $tag = Read-Host "  Version label? (e.g. V2, V2-before-submission; leave blank to auto)"
               if ($tag) { & "$aiRoot\snapshot.ps1" -Project $proj -Tag $tag }
               else      { & "$aiRoot\snapshot.ps1" -Project $proj }
           }
        9  {
               $rollN = 1
               $input = Read-Host "  Commits to roll back? (default 1)"
               if ($input -match "^\d+$") { $rollN = [int]$input }
               & "$aiRoot\rollback.ps1" -Project $proj -N $rollN
           }
        10 {
               $projRoot   = Resolve-ProjectRoot $proj
               $stagingDir = Join-Path $projRoot "_submit_staging"
               $hasCover   = Test-Path (Join-Path $stagingDir "cover_letter.pdf")
               if (!$hasCover) {
                   Write-Host ""
                   Write-Host "  No staged AI content found -- generating via Claude..." -ForegroundColor Cyan
                   $promptText = Get-Content (Join-Path $aiRoot "prompts\submit_stage_ai.md") -Raw -Encoding UTF8
                   Push-Location $projRoot
                   & claude -p $promptText
                   Pop-Location
               } else {
                   Write-Host "  Staged AI content found -- skipping Claude generation." -ForegroundColor DarkGray
               }
               & "$aiRoot\submit.ps1" -Project $proj
           }
        11 {
               $projRoot   = Resolve-ProjectRoot $proj
               $round      = Read-Host "  Round? (e.g. R1, R2)"
               if (!$round) { $round = "R1" }
               $promptText = (Get-Content (Join-Path $aiRoot "prompts\respond_scaffold.md") -Raw -Encoding UTF8) -replace '\$ROUND', $round
               Push-Location $projRoot
               & claude -p $promptText
               Pop-Location
           }
        12 {
               $projRoot   = Resolve-ProjectRoot $proj
               $round      = Read-Host "  Round? (e.g. R1, R2)"
               if (!$round) { $round = "R1" }
               $promptText = (Get-Content (Join-Path $aiRoot "prompts\respond_draft.md") -Raw -Encoding UTF8) -replace '\$ROUND', $round
               Push-Location $projRoot
               & claude -p $promptText
               Pop-Location
           }
        13 { & "$aiRoot\status.ps1" }
        14 { & "$aiRoot\network.ps1" }
        15 { Start-Process "$aiRoot\infrastructure.html" }
        16 { & "$aiRoot\generate_docs.ps1" }
        17 { Show-ClaudeCheatsheet }
        18 { Toggle-ModelCheck }
        19 { if ($texFile) { & "$aiRoot\generate_slides.ps1" -Project $proj -Preset $texFile }
             else          { & "$aiRoot\generate_slides.ps1" -Project $proj } }
        20 { & "$aiRoot\restore.ps1" }
        21 { & "$aiRoot\setup.ps1" }
        22 { & "$aiRoot\compress_log.ps1" -Project $proj }
    }
}

# ── Claude Code cheatsheet row helper ─────────────────────────────
function Write-CheatRow([string]$cmd, [string]$desc) {
    Write-Host ("  {0,-26} {1}" -f $cmd, $desc) -ForegroundColor White
}

# ── Claude Code in-session cheatsheet ─────────────────────────────
function Show-ClaudeCheatsheet {
    $sep = "  " + ("-" * 71)

    Write-Host ""
    Write-Host "  Claude Code -- in-session command reference" -ForegroundColor Cyan
    Write-Host $sep -ForegroundColor DarkGray

    Write-Host "  SESSION + MODEL" -ForegroundColor DarkYellow
    Write-CheatRow "/model"        "Switch model mid-session (keeps full history)"
    Write-CheatRow "/fast"         "Toggle fast mode -- Opus 4.6 with faster streaming"
    Write-CheatRow "/compact"      "Compress history to save tokens (run at task breaks)"
    Write-CheatRow "/clear"        "Wipe conversation history and start fresh"
    Write-CheatRow "/cost"         "Show token usage + estimated cost for this session"
    Write-CheatRow "/help"         "Built-in Claude Code help"
    Write-Host $sep -ForegroundColor DarkGray

    Write-Host "  PROJECT SKILLS  (custom -- from ~/.claude/commands/)" -ForegroundColor DarkYellow
    Write-CheatRow "/work [path]"  "Load research project context + session discipline"
    Write-CheatRow "/close"        "End session: write _ai_log.md block + handover"
    Write-CheatRow "/helpi [N] [proj]" "Run any helpi command without leaving Claude"
    Write-CheatRow "/snapshot"     "Git-tag current Overleaf source as named version"
    Write-CheatRow "/submit"       "Build journal submission package"
    Write-CheatRow "/respond"      "Reviewer response loop (scaffold -> draft)"
    Write-CheatRow "/family"       "Link feeder projects + build digests"
    Write-CheatRow "/add-memory"   "Add a file or note to project feeder memory"
    Write-Host $sep -ForegroundColor DarkGray

    Write-Host "  SHELL" -ForegroundColor DarkYellow
    Write-CheatRow "! [cmd]"       "Run a shell command inline  (e.g. ! git log --oneline)"
    Write-CheatRow "/helpi 17"     "Show this cheatsheet from inside a Claude session"
    Write-Host $sep -ForegroundColor DarkGray

    Write-Host "  MODEL IDS  (use with --model flag or /model)" -ForegroundColor DarkYellow
    Write-CheatRow "claude-haiku-4-5-20251001"  "Haiku  -- fast, cheap, simple tasks"
    Write-CheatRow "claude-sonnet-4-6"           "Sonnet -- default, balanced"
    Write-CheatRow "claude-opus-4-7"             "Opus   -- most capable, slower"
    Write-Host $sep -ForegroundColor DarkGray

    Write-Host "  TIPS" -ForegroundColor DarkYellow
    Write-Host "  - /model keeps history;  'claude --model X' starts a fresh session." -ForegroundColor DarkGray
    Write-Host "  - Run /compact every ~10 exchanges to keep costs low." -ForegroundColor DarkGray
    Write-Host "  - helpi 17 from terminal;  '! helpi 17' from inside Claude." -ForegroundColor DarkGray
    Write-Host ""
}

# ── Toggle Claude model-check behavior ────────────────────────────
function Toggle-ModelCheck {
    $memFile = "$claudeDir\projects\$claudeProjectKey\memory\feedback_model_assessment.md"
    if (!(Test-Path $memFile)) {
        Write-Host "ERR | Memory file not found: $memFile" -ForegroundColor Red
        return
    }
    $content = Get-Content $memFile -Raw -Encoding UTF8
    if ($content -match "STATUS: DISABLED") {
        $content = $content -replace "`nSTATUS: DISABLED`n", "`n"
        Set-Content $memFile $content -Encoding UTF8 -NoNewline
        Write-Host ""
        Write-Host "  Model-check ENABLED -- Claude will suggest Haiku when appropriate." -ForegroundColor Green
    } else {
        $content = $content -replace "(\-\-\-\r?\n)", "`$1`nSTATUS: DISABLED`n"
        Set-Content $memFile $content -Encoding UTF8 -NoNewline
        Write-Host ""
        Write-Host "  Model-check DISABLED -- Claude will skip model suggestions." -ForegroundColor Yellow
    }
    Write-Host "  Takes effect from the next Claude session. Tell Claude 'model check off/on' for the current session." -ForegroundColor DarkGray
    Write-Host ""
}

# ── Entry point ────────────────────────────────────────────────────
if (!$Project) { $Project = Get-ProjectFromCwd }

# Help mode: helpi 5 ?
if ($Project -in @('?','help')) {
    if ($Cmd -match "^\d+$") {
        Show-CommandHelp -n ([int]$Cmd) -proj (Get-ProjectFromCwd)
    } else {
        Write-Host "  Usage: helpi <N> ?" -ForegroundColor Yellow
    }
    return
}

if (-not $Cmd) {
    Show-Menu -forProject $Project
} elseif ($Cmd -match "^\d+$") {
    $n = [int]$Cmd
    if ($n -lt 1 -or $n -gt $commands.Count) {
        Write-Host "ERR | Valid commands are 1-$($commands.Count)" -ForegroundColor Red
        Show-Menu -forProject $Project
    } else {
        Invoke-Command-N -n $n -proj $Project -texFile $TexFile
    }
} else {
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
