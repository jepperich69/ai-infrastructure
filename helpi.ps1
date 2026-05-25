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
    [string]$TexFile = "",
    [string]$Agent   = "",
    [string]$Mode    = "",
    [switch]$Force
)

. "$PSScriptRoot\config.ps1"

$ForumTemplateNames = @("lit-review", "math-verify", "repro-audit", "final-pass", "code-audit")

# ── Auto-detect project from current working directory ─────────────
function Get-ProjectFromCwd {
    $cwd = (Get-Location).Path

    $pubPrefix = "$pubRoot\"
    if ($cwd.StartsWith($pubPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        $relative = $cwd.Substring($pubPrefix.Length)
        $project  = ($relative -split '[\\/]')[0]
        if ($project -match '^(Pub_|Pro_|PhD_)') { return $project }
    }

    $segments = $cwd -split '[\\/]'
    $match = $segments | Where-Object {
        $_ -match '^(Pub_|Pro_|PhD_|AI_auto|CV|CHARGO|42180|DFF|Reagent|BeamerPres|hEART|IATBR|Cycling|Discrete|EV|Paulsen|Presentation|Aalborg|Bicycle|Slides)'
    } | Select-Object -First 1
    if ($match) { return $match } else { return "" }
}


# ── Active project fallback ───────────────────────────────────────
$helpiStateDir  = Join-Path $aiRoot '_state'
$helpiStateFile = Join-Path $helpiStateDir 'last_project.txt'

function Get-LastProject {
    if (Test-Path $helpiStateFile) {
        return (Get-Content $helpiStateFile -Encoding UTF8 | Select-Object -First 1).Trim()
    }
    return ""
}

function Set-LastProject([string]$proj) {
    if (!$proj) { return }
    if (!(Test-Path $helpiStateDir)) { New-Item -ItemType Directory -Path $helpiStateDir -Force | Out-Null }    
    Set-Content -Path $helpiStateFile -Value $proj -Encoding UTF8
}

function Test-ForumTemplateName([string]$value) {
    if (!$value) { return $false }
    return $ForumTemplateNames -contains $value.ToLowerInvariant()
}

function Resolve-ForumProjectFallback {
    $proj = Get-ProjectFromCwd
    if (!$proj) { $proj = Get-LastProject }
    return $proj
}

# helpi 25 supports compact template syntax:
#   helpi 25 code-audit
#   helpi 25 code-audit -Agent codex -Mode SAD
if ($Cmd -eq "25" -and (Test-ForumTemplateName $Project) -and !$TexFile) {
    $TexFile = $Project
    $Project = Resolve-ForumProjectFallback
}

# ── Command definitions ────────────────────────────────────────────
$commands = @(
    [PSCustomObject]@{ N=1;  NeedsProject=$true;  Tag="ONCE";    Name="Create new project";
         Example="new_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=2;  NeedsProject=$false; Tag="AUTO 4h"; Name="Pull all projects from Overleaf";           Example="sync_all.ps1" },
    [PSCustomObject]@{ N=3;  NeedsProject=$true;  Tag="MANUAL";  Name="Pull one project from Overleaf";         
   Example="sync_one.ps1 -Project XXX" },
    [PSCustomObject]@{ N=4;  NeedsProject=$true;  Tag="MANUAL";  Name="Push local edits to Overleaf";           
   Example="push_to_overleaf.ps1 -Project XXX" },
    [PSCustomObject]@{ N=5;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile + open project (VS Code + PDF)";    Example="open_project.ps1 -Project XXX" },
    [PSCustomObject]@{ N=6;  NeedsProject=$true;  Tag="MANUAL";  Name="Compile LaTeX + open PDF";
         Example="compile_latex.ps1 -Project XXX" },
    [PSCustomObject]@{ N=7;  NeedsProject=$true;  Tag="MANUAL";  Name="Log + handover + open in browser";          Example="claude -p close.md + handover in XXX" },
    [PSCustomObject]@{ N=8;  NeedsProject=$true;  Tag="MANUAL";  Name="Snapshot Overleaf source (git tag)";        Example="snapshot.ps1 -Project XXX [-Tag V2]" },
    [PSCustomObject]@{ N=9;  NeedsProject=$true;  Tag="MANUAL";  Name="Rollback last N code commits";           
   Example="rollback.ps1 -Project XXX -N 1" },
    [PSCustomObject]@{ N=10; NeedsProject=$true;  Tag="MANUAL";  Name="Build submission package";
         Example="submit.ps1 -Project XXX" },
    [PSCustomObject]@{ N=11; NeedsProject=$true;  Tag="MANUAL";  Name="Reviewer scaffold (.txt -> LaTeX + push)";  Example="respond_scaffold.md in XXX" },
    [PSCustomObject]@{ N=12; NeedsProject=$true;  Tag="MANUAL";  Name="Reviewer draft loop (pull -> draft -> push)";Example="respond_draft.md in XXX" },
    [PSCustomObject]@{ N=13; NeedsProject=$false; Tag="INFO";    Name="Project status dashboard";
         Example="status.ps1" },
    [PSCustomObject]@{ N=14; NeedsProject=$false; Tag="INFO";    Name="Open project network graph";             
   Example="network.ps1" },
    [PSCustomObject]@{ N=15; NeedsProject=$false; Tag="INFO";    Name="Open infrastructure guide";              
   Example="Start-Process infrastructure.html" },
    [PSCustomObject]@{ N=16; NeedsProject=$false; Tag="MANUAL";  Name="Generate docs (summary + full HTML/PDF)";   Example="generate_docs.ps1" },
    [PSCustomObject]@{ N=17; NeedsProject=$false; Tag="INFO";    Name="Claude Code in-session command reference";   Example="(cheatsheet -- no args needed)" },
    [PSCustomObject]@{ N=18; NeedsProject=$false; Tag="MANUAL";  Name="Toggle Claude model-check on/off";            Example="(edits memory -- persists to next session)" },
    [PSCustomObject]@{ N=19; NeedsProject=$true;  Tag="MANUAL";  Name="Generate Beamer slides from paper";            Example="generate_slides.ps1 -Project XXX" },
    [PSCustomObject]@{ N=20; NeedsProject=$false; Tag="ONCE";    Name="Restore infrastructure on replacement machine"; Example="restore.ps1" },
    [PSCustomObject]@{ N=21; NeedsProject=$false; Tag="ONCE";    Name="First-time setup for a new user/colleague";    Example="setup.ps1" },
    [PSCustomObject]@{ N=22; NeedsProject=$true;  Tag="MANUAL";  Name="Compress AI log (trim old sessions)";           Example="compress_log.ps1 -Project XXX" },
    [PSCustomObject]@{ N=23; NeedsProject=$true;  Tag="MANUAL";  Name="Push code/ to GitHub";
         Example="push_to_github.ps1 -Project XXX" },
    [PSCustomObject]@{ N=24; NeedsProject=$true;  Tag="MANUAL";  Name="Boil paper to technical one-pager";              Example="generate_onepager.ps1 -Project XXX" },
    [PSCustomObject]@{ N=25; NeedsProject=$true;  Tag="MANUAL";  Name="Convergence Forum (Multi-agent/Single-agent debate)";
       Example="run_forum.ps1 -Project XXX -Task '...' [-Mode SAD]" }
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
            "Runs 'git pull' in Overleaf_source/ for the specified project.",
            "",
            "When to use: before opening a project to ensure you have the latest co-author edits.",
            "",
            "Example:",
            "  helpi 3 $p"
        )}
        4  { @(
            "Push local edits to Overleaf",
            "Runs git add, git commit -m 'AI sync', and git push in Overleaf_source/.",
            "",
            "When to use: after making changes to the manuscript locally.",
            "",
            "Example:",
            "  helpi 4 $p"
        )}
        5  { @(
            "Compile + open project (VS Code + PDF)",
            "Opens the project folder in VS Code, runs latexmk via compile_latex.ps1,",
            "and opens the resulting PDF in the default viewer.",
            "",
            "When to use: start of a working session.",
            "",
            "Example:",
            "  helpi 5 $p"
        )}
        6  { @(
            "Compile LaTeX + open PDF",
            "Runs latexmk -pdf on the main manuscript and opens the PDF.",
            "If several candidates exist, asks which one to compile.",
            "",
            "When to use: quick recompile to check formatting or references.",
            "",
            "Example:",
            "  helpi 6 $p"
        )}
        7  { @(
            "Log + handover + open in browser",
            "The standard session-close pipeline:",
            "(1) runs /close in Claude (if in an AI shell),",
            "(2) runs generate_handover.ps1 to build _handover.html,",
            "(3) opens _handover.html in the browser.",
            "",
            "When to use: end of a working session or major checkpoint.",
            "",
            "Example:",
            "  helpi 7 $p"
        )}
        8  { @(
            "Snapshot Overleaf source (git tag)",
            "Creates a named git tag in Overleaf_source/ and pushes it to Overleaf.",
            "Useful for versioning before a major rewrite or reviewer round.",
            "",
            "Example:",
            "  helpi 8 $p V1-before-Gunnar-comments"
        )}
        9  { @(
            "Rollback last N code commits",
            "Hard-resets the code/ repository to HEAD~N. PERMANENT.",
            "",
            "When to use: to undo a series of bad code changes or accidental deletions.",
            "",
            "Example:",
            "  helpi 9 $p 1"
        )}
        10 { @(
            "Build submission package",
            "The full 'prepare for submission' pipeline:",
            "(1) safety-pull, (2) compile, (3) check for missing refs,",
            "(4) bundle all .tex files (flattening includes), (5) bundle figures,",
            "(6) zip everything for journal/conference version,",
            "(7) copy generated cover letter / highlights / author statement.",
            "If no staged content exists, generates deterministic staging files locally.",
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
        23 { @(
            "Push code/ to GitHub",
            "Pushes the project's code/ git repo to GitHub.",
            "If no remote exists, creates the GitHub repo via gh CLI (no browser needed),",
            "sets it as origin, and pushes. If a remote already exists, just pushes.",
            "",
            "Default repo name: <project>-code (private). Override with -RepoName or -Visibility.",
            "Requires: gh CLI authenticated (gh auth login).",
            "",
            "Examples:",
            "  helpi 23 $p                           # push (create repo if needed)",
            "  helpi 23 $p my-repo-name              # custom repo name",
            "  helpi 23 $p my-repo-name public       # public repo"
        )}
        24 { @(
            "Boil paper to technical one-pager",
            "Reads the main .tex manuscript and generates a dense, self-contained LaTeX note",
            "distilling the primary technical contribution: core idea, key formula,",
            "solver / application connection, small illustrative check, and a boxed",
            "contribution structure.",
            "",
            "Output: Overleaf_source/technical_onepager.tex",
            "Style:  10pt article, 1.7cm margins, italic run-in headers, no citations,",
            "        no figures, no bibliography. Compiles to one A4 page.",
            "Text:   down-to-earth technical language and numbered display equations.",
            "Source: includes non-compiling LaTeX comments after major equations with",
            "        intuition, notation clarifications, and a short policy reflection.",
            "",
            "When to use: to share the idea quickly with a co-author, before writing the",
            "full paper, or as a communication note for a meeting.",
            "",
            "Source manuscript:",
            "  If several candidate .tex files exist, helpi asks which one to use.",
            "  In non-interactive shells, it refuses to guess; pass the file explicitly.",
            "  Passing a filename skips the picker.",
            "",
            "Agent selection:",
            "  -Agent auto detects Claude/Codex when run from an AI shell.",
            "  From a normal terminal, auto defaults to Claude.",
            "",
            "Examples:",
            "  helpi 24 $p",
            "  helpi 24 $p -Agent codex",
            "  helpi 24 $p main.tex -Agent codex"
        )}
        25 { @(
            "Convergence Forum (Multi-agent / Single-agent debate)",
            "Orchestrates a discussion forum between agents to reach consensus",
            "on a complex research task.",
            "",
            "Templates (Task shortcuts):",
            "  lit-review   Systematic literature search and gap detection",
            "  math-verify  Formal proof and notation audit",
            "  repro-audit  Code reproduction and artifact fidelity check",
            "  final-pass   7-pillar manuscript editorial audit",
            "",
            "Modes:",
            "  Forum (default): Multi-agent round-robin (Claude -> Gemini -> Codex).",
            "  SAD (Single-Agent Debate): One agent takes three roles sequentially:",
            "      Critic -> Advocate -> Realist (Judge).",
            "",
            "Uses a Blackboard model with compact agent digests for token efficiency.",
            "Full transcripts are saved to _forums/, while the next turn receives only",
            "forum_state.md: convergence log, active arena, parking lot, and latest digests.",
            "",
            "Arguments:",
            "  Task: The agenda or question to debate (required). Can be a template name.",
            "  Agents: Comma-separated list (default: claude,gemini,codex). In SAD mode,",
            "          uses only the first agent in the list.",
            "  Mode: 'Forum' or 'SAD'.",
            "",
            "Output: Timestamped folder in _forums/ with full transcripts and forum_state.md.",
            "",
            "When to use: to stress-test methodology, brainstorm, or resolve contradictions.",
            "",
            "Shortcut from inside a project or AI_auto:",
            "  helpi 25 code-audit",
            "  helpi 25 code-audit -Agent codex -Mode SAD",
            "",
            "Example (Multi-agent):",
            "  helpi 25 $p lit-review",
            "  helpi 25 $p code-audit",
            "  helpi 25 $p 'Auditing Theorem 3.1' -Agent gemini,claude",
            "",
            "Example (Single-agent debate):",
            "  helpi 25 $p repro-audit -Agent gemini -Mode SAD"
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
    param([int]$n, [string]$proj, [string]$texFile = "", [string]$agent = "")
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
        23 { if ($texFile) { "push_to_github.ps1 -Project $proj -RepoName $texFile" }
             else          { "push_to_github.ps1 -Project $proj" } }
        24 {
             $agentText = if ($agent) { " -Agent $agent" } else { "" }
             if ($texFile) { "generate_onepager.ps1 -Project $proj -TexFile $texFile$agentText" }
             else          { "generate_onepager.ps1 -Project $proj$agentText" }
           }
        25 {
             $modeText  = if ($Mode)    { " -Mode $Mode" }      else { "" }
             $agentText = if ($Agent)   { " -Agents $Agent" }   else { "" }
             if (!$texFile) {
                 $taskText = " -Task <required>"
             } elseif (Test-Path -LiteralPath $texFile -PathType Leaf -ErrorAction SilentlyContinue) {
                 $taskText = " -TaskFile '$texFile'"
             } else {
                 $taskText = " -Task '$texFile'"
             }
             "run_forum.ps1 -ProjectName $proj$taskText$agentText$modeText"
           }
    }
}

# ── Execute a command ──────────────────────────────────────────────
function Invoke-Command-N {
    param([int]$n, [string]$proj, [string]$texFile = "", [string]$agent = "")

    $c = $commands | Where-Object { $_.N -eq $n }
    if (!$c) { Write-Host "ERR | Unknown command: $n" -ForegroundColor Red; return }

    if ($n -eq 24 -and $texFile -match '^(?i)(auto|claude|codex)$' -and !$agent) {
        $agent = $texFile.ToLowerInvariant()
        $texFile = ""
    }

    if ($n -eq 24 -and $agent -and $agent -notmatch '^(?i)(auto|claude|codex)$') {
        Write-Host "ERR | helpi 24 -Agent must be auto, claude, or codex." -ForegroundColor Red
        return
    }

    # helpi 25 mapping: texFile is the task, agent is the agent list
    if ($n -eq 25 -and $texFile -match '^(?i)(claude|gemini|codex)(,.*)?$' -and !$agent) {
        $agent = $texFile
        $texFile = ""
    }

    if ($c.NeedsProject -and !$proj) {
        $proj = Get-LastProject
        if (!$proj) {
            $proj = Read-Host "  Project name"
        }
    }

    if ($proj) { Set-LastProject $proj }

    if ($n -eq 6 -and $Force -and !$texFile) {
        $projRoot  = Resolve-ProjectRoot $proj
        $sourceDir = Join-Path $projRoot "Overleaf_source"
        $candidate = Get-ChildItem $sourceDir -Filter "*.tex" -File |
                     Sort-Object LastWriteTime -Descending |
                     Select-Object -First 1
        if (!$candidate) {
            Write-Host "ERR | No .tex files found in $sourceDir" -ForegroundColor Red
            return
        }
        $texFile = $candidate.Name
    }

    $preview = Get-CommandPreview -n $n -proj $proj -texFile $texFile -agent $agent
    Write-Host ""
    Write-Host "  [$n] $($c.Name)$(if ($proj) { "  ->  $proj" })" -ForegroundColor Cyan
    Write-Host "  $preview" -ForegroundColor DarkYellow
    Write-Host ""
    
    $runNow = $Force -or [Console]::IsInputRedirected
    if (!$runNow) {
        Write-Host "  [Enter] run  |  [any other key] cancel  (press Up to edit at prompt)" -ForegroundColor DarkGray
        try { [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($preview) } catch {}
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host ""
        if ($key.VirtualKeyCode -eq 13) { $runNow = $true }
    }

    if (!$runNow) { return }

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
               & claude -p $closePrompt --model claude-haiku-4-5-20251001
               Pop-Location
               & "$aiRoot\generate_handover.ps1" -Project $proj
               $html = Join-Path $projRoot "_handover.html"
               if (Test-Path $html) {
                   try { Start-Process $html } catch { Write-Host "WARN | Could not open handover in browser: $($_.Exception.Message)" -ForegroundColor Yellow }
               }
           }
        8  {
               $tag = if ($Force) { "" } else { Read-Host "  Version label? (e.g. V2, V2-before-submission; leave blank to auto)" }
               if ($tag) { & "$aiRoot\snapshot.ps1" -Project $proj -Tag $tag }
               else      { & "$aiRoot\snapshot.ps1" -Project $proj }
           }
        9  {
               $rollN = 1
               if (!$Force) {
                   $input = Read-Host "  Commits to roll back? (default 1)"
                   if ($input -match "^\d+$") { $rollN = [int]$input }
               }
               & "$aiRoot\rollback.ps1" -Project $proj -N $rollN
           }
        10 {
               $projRoot   = Resolve-ProjectRoot $proj
               $stagingDir = Join-Path $projRoot "_submit_staging"
               $hasCover   = Test-Path (Join-Path $stagingDir "cover_letter.pdf")
               if (!$hasCover) {
                   Write-Host ""
                   Write-Host "  No staged submission content found -- generating locally..." -ForegroundColor Cyan
                   & "$aiRoot\stage_submission_ai.ps1" -Project $proj
               } else {
                   Write-Host "  Staged AI content found -- skipping Claude generation." -ForegroundColor DarkGray
               }
               & "$aiRoot\submit.ps1" -Project $proj
           }
        11 {
               $projRoot   = Resolve-ProjectRoot $proj
               $round      = if ($Force -or [Console]::IsInputRedirected) { "R1" } else { Read-Host "  Round? (e.g. R1, R2)" }
               if (!$round) { $round = "R1" }
               $promptText = (Get-Content (Join-Path $aiRoot "prompts\respond_scaffold.md") -Raw -Encoding UTF8) -replace '\$ROUND', $round
               Push-Location $projRoot
               & claude -p $promptText
               Pop-Location
           }
        12 {
               $projRoot   = Resolve-ProjectRoot $proj
               $round      = if ($Force -or [Console]::IsInputRedirected) { "R1" } else { Read-Host "  Round? (e.g. R1, R2)" }
               if (!$round) { $round = "R1" }
               $promptText = (Get-Content (Join-Path $aiRoot "prompts\respond_draft.md") -Raw -Encoding UTF8) -replace '\$ROUND', $round
               Push-Location $projRoot
               & claude -p $promptText
               Pop-Location
           }
        13 { & "$aiRoot\status.ps1" }
        14 { & "$aiRoot\network.ps1" }
        15 {
               try { Start-Process "$aiRoot\infrastructure.html" } catch { Write-Host "WARN | Could not open infrastructure guide: $($_.Exception.Message)" -ForegroundColor Yellow }
           }
        16 { & "$aiRoot\generate_docs.ps1" }
        17 { Show-ClaudeCheatsheet }
        18 { Toggle-ModelCheck }
        19 { if ($texFile) { & "$aiRoot\generate_slides.ps1" -Project $proj -Preset $texFile }
             else          { & "$aiRoot\generate_slides.ps1" -Project $proj } }
        20 { & "$aiRoot\restore.ps1" }
        21 { & "$aiRoot\setup.ps1" }
        22 { & "$aiRoot\compress_log.ps1" -Project $proj }
        23 { if ($texFile) { & "$aiRoot\push_to_github.ps1" -Project $proj -RepoName $texFile }
             else          { & "$aiRoot\push_to_github.ps1" -Project $proj } }
        24 { if ($texFile) { & "$aiRoot\generate_onepager.ps1" -Project $proj -TexFile $texFile -Agent $(if ($agent) { $agent } else { "gemini" }) }
             else          { & "$aiRoot\generate_onepager.ps1" -Project $proj -Agent $(if ($agent) { $agent } else { "gemini" }) } }
        25 {
             if (!$texFile -and !$Force) {
                 if ([Console]::IsInputRedirected) {
                     Write-Host "ERR | helpi 25 requires a task argument in non-interactive shells." -ForegroundColor Red
                     Write-Host ""
                     Write-Host "  Templates:  lit-review | math-verify | repro-audit | final-pass | code-audit" -ForegroundColor DarkGray
                     Write-Host "  Usage:      helpi 25 $proj code-audit" -ForegroundColor DarkGray
                     Write-Host "              helpi 25 $proj lit-review -Mode SAD -Agent gemini" -ForegroundColor DarkGray
                     Write-Host "              helpi 25 $proj 'C:\path\to\task.txt'" -ForegroundColor DarkGray
                     Write-Host ""
                     return
                 }

                 Write-Host ""
                 Write-Host "  Select a Convergence Forum template:" -ForegroundColor Cyan
                 Write-Host "  [1] lit-review   (Literature search and gap detection)"
                 Write-Host "  [2] math-verify  (Formal proof and notation audit)"
                 Write-Host "  [3] repro-audit  (Code reproduction and artifact fidelity)"
                 Write-Host "  [4] final-pass   (7-pillar manuscript editorial audit)"
                 Write-Host "  [5] code-audit   (Syntax check and architectural opinion)"
                 Write-Host "  [6] Custom task..."
                 Write-Host ""
                 $choice = Read-Host "  Selection [1-6]"

                 $templateMap = @{
                     "1" = "lit-review"
                     "2" = "math-verify"
                     "3" = "repro-audit"
                     "4" = "final-pass"
                     "5" = "code-audit"
                 }

                 if ($templateMap.ContainsKey($choice)) {
                     $texFile = $templateMap[$choice]
                     Write-Host "  Selected template: $texFile" -ForegroundColor Gray
                 } else {
                     $texFile = Read-Host "  Task text or path to .txt/.md file"
                     if (!$texFile) {
                         Write-Host "ERR | No forum task provided." -ForegroundColor Red
                         return
                     }
                 }
             }

             if (!$Mode -and !$Force -and ![Console]::IsInputRedirected) {
                 Write-Host ""
                 Write-Host "  Select forum mode:" -ForegroundColor Cyan
                 Write-Host "  [1] Forum  (Multi-agent)"
                 Write-Host "  [2] SAD    (Single-agent debate)"
                 Write-Host ""
                 $mChoice = Read-Host "  Selection [1-2, default 1]"
                 if ($mChoice -eq "2") {
                     $Mode = "SAD"
                     if (!$agent) {
                         Write-Host ""
                         Write-Host "  Select agent for SAD debate:" -ForegroundColor Cyan
                         Write-Host "  [1] Claude"
                         Write-Host "  [2] Gemini"
                         Write-Host "  [3] Codex"
                         Write-Host ""
                         $aChoice = Read-Host "  Selection [1-3, default 1]"
                         $agent = switch ($aChoice) {
                             "2"     { "gemini" }
                             "3"     { "codex" }
                             default { "claude" }
                         }
                         Write-Host "  Selected agent: $agent" -ForegroundColor Gray
                     }
                 } else {
                     $Mode = "Forum"
                 }
                 Write-Host "  Selected mode: $Mode" -ForegroundColor Gray
             }

             # Fallbacks for headless/Force mode
             if (!$texFile) { $texFile = "final-pass" }
             if (!$Mode)    { $Mode = "Forum" }

             $forumParams = @{ ProjectName = $proj }
             if (Test-Path -LiteralPath $texFile -PathType Leaf -ErrorAction SilentlyContinue) {
                 $forumParams.TaskFile = $texFile
             } else {
                 $forumParams.Task = $texFile
             }
             if ($agent) { $forumParams.Agents = $agent }
             if ($Mode)  { $forumParams.Mode   = $Mode }
             & "$aiRoot\run_forum.ps1" @forumParams
           }
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
if (!$Project) { $Project = Get-LastProject }
if ($Project) { Set-LastProject $Project }

# Help mode: helpi 5 ?
if ($Project -in @('?','help')) {
    if ($Cmd -match "^\d+$") {
        Show-CommandHelp -n ([int]$Cmd) -proj (Get-ProjectFromCwd)
    } else {
        Write-Host "  Usage: helpi <N> ?" -ForegroundColor Yellow
    }
    return
}

if ($TexFile -in @('?','help')) {
    if ($Cmd -match "^\d+$") {
        Show-CommandHelp -n ([int]$Cmd) -proj $Project
    } else {
        Write-Host "  Usage: helpi <N> <Project> ?" -ForegroundColor Yellow
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
        Invoke-Command-N -n $n -proj $Project -texFile $TexFile -agent $Agent
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
        Invoke-Command-N -n $m.N -proj $Project -texFile $TexFile -agent $Agent
    } else {
        Write-Host ""
        Write-Host "  '$Cmd' matches multiple commands:" -ForegroundColor Yellow
        foreach ($m in $found) {
            Write-Host ("    [{0,2}]  {1}" -f $m.N, $m.Name) -ForegroundColor White
        }
        Write-Host ""
    }
}
