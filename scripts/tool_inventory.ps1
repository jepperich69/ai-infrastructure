# tool_inventory.ps1
# Probes this machine for the tools the JR infrastructure depends on and
# regenerates AI_auto\TOOLS.md.
#
# Why generated rather than hand-written: three hand-maintained tool lists had
# already drifted apart by 2026-08 (the known_issues.md table was stale on four
# versions and missing ten tools). A list nobody re-runs is a list nobody can
# trust on the day the machine is replaced. Run this after installing anything.
#
# TOOLS.md is the inventory: what is here now, with versions and paths.
# INSTALL.md Part B is the plan: what to install on a new machine, in order.
# known_issues.md holds the traps for individual tools.
#
# Usage:
#   tool_inventory.ps1            # probe, rewrite TOOLS.md, print summary
#   tool_inventory.ps1 -Quiet     # rewrite TOOLS.md only
#   helpi 29

param(
    [switch]$Quiet
)

. "$PSScriptRoot\config.ps1"

$repoRoot = Split-Path $PSScriptRoot -Parent
$outFile  = Join-Path $repoRoot "TOOLS.md"

# -- Tool definitions ---------------------------------------------------
# Command : resolved on PATH first.
# Paths   : fallback candidates, globs allowed, newest match wins.
# NoRun   : probe existence only, never execute (agy hangs when run headless).
# Need    : required | optional | absent  ("absent" = deliberately not installed)
$tools = @(
    @{ Name='PowerShell 7'; Cat='Core'; Command='pwsh'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='Every helpi script'; Install='winget install Microsoft.PowerShell' }

    @{ Name='Git'; Cat='Core'; Command='git'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='Everything'; Install='https://git-scm.com/download/win' }

    @{ Name='GitHub CLI'; Cat='Core'; Command='gh'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='helpi 23, auth'; Install='https://cli.github.com' }

    @{ Name='Node.js'; Cat='Core'; Command='node'; VerArgs=@('--version'); Rx='v?(\d+\.\d+\.\d+)'
       Need='required'; Why='Provides the agent CLIs via npm'; Install='https://nodejs.org' }

    @{ Name='VS Code'; Cat='Core'; Command='code'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='helpi 5 opens projects here'; Install='https://code.visualstudio.com' }

    @{ Name='Claude Code'; Cat='Agents'; Command='claude'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='The agent'; Install='https://claude.ai/download' }

    @{ Name='Gemini CLI'; Cat='Agents'; Command='gemini'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='optional'; Why='helpi 25 forum, NoteTaker transcription'
       Install='npm install -g @google/gemini-cli' }

    @{ Name='Codex CLI'; Cat='Agents'; Command='codex'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='optional'; Why='helpi 24/25 with -Agent codex'; Install='npm install -g @openai/codex' }

    @{ Name='Supabase CLI'; Cat='Agents'; Command='supabase'; VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='optional'; Why='NoteTaker only'; Install='npm install -g supabase' }

    @{ Name='Antigravity (agy)'; Cat='Agents'; Paths=@('C:\Users\*\AppData\Local\agy\bin\agy.exe')
       NoRun=$true; Need='optional'; Why='Interactive only, never automated'
       Install='PIN v1.0.8 -- do NOT update'; Ref='#37' }

    @{ Name='MiKTeX (pdflatex)'; Cat='LaTeX'; Command='pdflatex'; VerArgs=@('--version'); Rx='MiKTeX ([\d.]+)'
       Need='required'; Why='helpi 5/6 compile'; Install='https://miktex.org/download' }

    @{ Name='latexmk'; Cat='LaTeX'; Command='latexmk'; VerArgs=@('--version'); Rx='Version ([\d.]+)'
       Need='required'; Why='Compile driver'; Install='ships with MiKTeX' }

    @{ Name='latexdiff'; Cat='LaTeX'; Command='latexdiff'; VerArgs=@('--version'); Rx='LATEXDIFF ([\d.]+)'
       Need='required'; Why='submit.ps1 tracked-changes PDF'; Install='ships with MiKTeX' }

    @{ Name='Strawberry Perl'; Cat='LaTeX'; Command='perl'; VerArgs=@('--version'); Rx='v(\d+\.\d+\.\d+)'
       Need='required'; Why='Runs latexdiff'; Install='https://strawberryperl.com' }

    @{ Name='Python (miniconda)'; Cat='Numerical'
       Paths=@('C:\Users\*\AppData\Local\miniconda3\python.exe'); VerArgs=@('-V'); Rx='(\d+\.\d+\.\d+)'
       Need='required'; Why='Project code; NOT on PATH by design'
       Install='https://docs.conda.io/en/latest/miniconda.html'; Ref='#45' }

    @{ Name='R'; Cat='Numerical'; Paths=@('C:\Users\*\AppData\Local\Programs\R\R-*\bin\R.exe')
       VerArgs=@('--version'); Rx='R version (\d+\.\d+\.\d+)'
       Need='required'; Why='Project code; NOT on PATH'; Install='https://cran.r-project.org' }

    @{ Name='Gurobi'; Cat='Numerical'; Command='gurobi_cl'; VerArgs=@('--version'); Rx='version ([\d.]+)'
       Need='optional'; Why='jr_optlib exact benchmarks, selected MIP/MIQP'
       Install='conda install -c gurobi gurobi (needs a licence)' }

    # Version comes from the install folder: the bundled python.exe would report
    # its own version (3.12.x), not QGIS's.
    @{ Name='QGIS LTR'; Cat='Numerical'; Paths=@('C:\Program Files\QGIS *\apps\Python3*\python.exe')
       VerFromPath='QGIS (\d+\.\d+\.\d+)'
       Need='optional'; Why='Maps, geoprocessing; wire in per project with helpi 28'
       Install='https://qgis.org/download (LTR)'; Ref='#50' }

    @{ Name='Biogeme (venv)'; Cat='Numerical'; Paths=@('C:\Users\*\venvs\biogeme313\Scripts\python.exe')
       VerArgs=@('-c', 'import importlib.metadata as m; print(m.version("biogeme"))'); Rx='([\d.]+)'
       Need='optional'; Why='Discrete choice estimation'
       Install='python -m venv C:\Users\rich\venvs\biogeme313; pip install biogeme==3.3.4'; Ref='#51' }

    @{ Name='Scalene'; Cat='Profiling'; Paths=@('C:\Users\*\AppData\Local\miniconda3\Scripts\scalene.exe')
       VerArgs=@('--version'); Rx='version (\d+\.\d+\.\d+)'
       Need='optional'; Why='Line profiler; splits Python from native time'
       Install='pip install scalene (into the env that runs the code)'; Ref='PROFILING.md' }

    @{ Name='py-spy'; Cat='Profiling'; Paths=@('C:\Users\*\AppData\Local\miniconda3\Scripts\py-spy.exe')
       VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='optional'; Why='Attaches to an already-running process by PID'
       Install='pip install py-spy'; Ref='PROFILING.md' }

    @{ Name='VizTracer'; Cat='Profiling'; Paths=@('C:\Users\*\AppData\Local\miniconda3\Scripts\viztracer.exe')
       VerArgs=@('--version'); Rx='(\d+\.\d+\.\d+)'
       Need='optional'; Why='Interactive timeline trace'
       Install='pip install viztracer'; Ref='PROFILING.md' }

    @{ Name='pydeps'; Cat='Profiling'; Paths=@('C:\Users\*\AppData\Local\miniconda3\Scripts\pydeps.exe')
       VerArgs=@('--version'); Rx='v?(\d+\.\d+\.\d+)'
       Need='optional'; Why='Module import graph; needs Graphviz'
       Install='pip install pydeps'; Ref='PROFILING.md' }

    @{ Name='Graphviz'; Cat='Profiling'; Paths=@('C:\Program Files\Graphviz\bin\dot.exe')
       VerArgs=@('-V'); Rx='version (\d+\.\d+\.\d+)'
       Need='optional'; Why='Renders pydeps output; installed but NOT on PATH'
       Install='winget install Graphviz.Graphviz'; Ref='PROFILING.md' }

    @{ Name='Stata'; Cat='Not installed'; Command='stata'; Need='absent'; Why='Not used' }
    @{ Name='Julia';  Cat='Not installed'; Command='julia'; Need='absent'; Why='Not used' }
)

# -- Probe --------------------------------------------------------------
function Resolve-ToolPath($t) {
    if ($t.Command) {
        $c = Get-Command $t.Command -ErrorAction SilentlyContinue
        if ($c) { return $c.Source }
    }
    foreach ($pattern in @($t.Paths)) {
        if (!$pattern) { continue }
        $hit = Get-Item -Path $pattern -ErrorAction SilentlyContinue |
               Sort-Object FullName -Descending | Select-Object -First 1
        if ($hit) { return $hit.FullName }
    }
    return $null
}

function Get-ToolVersion($t, $path) {
    if (!$path) { return "--" }
    # Some tools are identified by where they live, not by what they print.
    if ($t.VerFromPath) {
        if ($path -match $t.VerFromPath) { return $Matches[1] }
        return "?"
    }
    if ($t.NoRun) { return "--" }
    try {
        $raw = & $path @($t.VerArgs) 2>&1 | Out-String
    } catch { return "?" }
    if (!$raw) { return "?" }
    if ($t.Rx -and $raw -match $t.Rx) { return $Matches[1] }
    $first = ($raw -split "`n" | Where-Object { $_.Trim() } | Select-Object -First 1)
    if ($first) { return $first.Trim() } else { return "?" }
}

$results = foreach ($t in $tools) {
    $path = Resolve-ToolPath $t
    [PSCustomObject]@{
        Name    = $t.Name
        Cat     = $t.Cat
        Need    = $t.Need
        Why     = $t.Why
        Install = $t.Install
        Ref     = $t.Ref
        Path    = $path
        Version = Get-ToolVersion $t $path
        Present = [bool]$path
        NoRun   = [bool]$t.NoRun
    }
}

# -- Write TOOLS.md -----------------------------------------------------
$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# Tool inventory -- this machine")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Generated by ``helpi 29`` (``scripts/tool_inventory.ps1``) on $stamp.")
[void]$sb.AppendLine("**Do not hand-edit.** Install something, then re-run.")
[void]$sb.AppendLine()
[void]$sb.AppendLine("This is the inventory: what is on the machine now. The install *plan* for a")
[void]$sb.AppendLine("replacement machine is INSTALL.md Part B. Per-tool traps are in known_issues.md.")
[void]$sb.AppendLine()

foreach ($cat in @('Core','Agents','LaTeX','Numerical','Profiling','Not installed')) {
    $rows = $results | Where-Object { $_.Cat -eq $cat }
    if (!$rows) { continue }
    [void]$sb.AppendLine("## $cat")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("| Tool | Version | Path | Need | Notes |")
    [void]$sb.AppendLine("|---|---|---|---|---|")
    foreach ($r in $rows) {
        $status = if ($r.Present) { $r.Version } elseif ($r.Need -eq 'absent') { "not installed" } else { "**MISSING**" }
        $p = if ($r.Path) { '`' + $r.Path + '`' } else { "--" }
        # Refs are either a known_issues number (#50) or a document name.
        $ref = if (!$r.Ref) { $null }
               elseif ($r.Ref.StartsWith('#')) { "see known_issues $($r.Ref)" }
               else { "see $($r.Ref)" }
        $note = @($r.Why, $ref) | Where-Object { $_ }
        [void]$sb.AppendLine("| $($r.Name) | $status | $p | $($r.Need) | $($note -join '; ') |")
    }
    [void]$sb.AppendLine()
}

$condaEnvs = Get-ChildItem "$env:USERPROFILE\AppData\Local\miniconda3\envs" -Directory -ErrorAction SilentlyContinue |
             Select-Object -ExpandProperty Name
[void]$sb.AppendLine("## Python environments")
[void]$sb.AppendLine()
[void]$sb.AppendLine("Conda envs: ``base`` plus " + $(if ($condaEnvs) { ($condaEnvs | ForEach-Object { "``$_``" }) -join ', ' } else { "none" }))
[void]$sb.AppendLine()
$venvs = Get-ChildItem "$env:USERPROFILE\venvs" -Directory -ErrorAction SilentlyContinue
if ($venvs) {
    [void]$sb.AppendLine("Standalone venvs in ``$env:USERPROFILE\venvs`` (deliberately outside OneDrive):")
    [void]$sb.AppendLine()
    foreach ($v in $venvs) {
        $sz = (Get-ChildItem $v.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        [void]$sb.AppendLine("- ``$($v.Name)`` -- {0:N0} MB" -f ($sz / 1MB))
    }
    [void]$sb.AppendLine()
}

$missing = $results | Where-Object { -not $_.Present -and $_.Need -ne 'absent' }
[void]$sb.AppendLine("## Missing")
[void]$sb.AppendLine()
if ($missing) {
    foreach ($m in $missing) {
        [void]$sb.AppendLine("- **$($m.Name)** ($($m.Need)) -- $($m.Why). Install: ``$($m.Install)``")
    }
} else {
    [void]$sb.AppendLine("Nothing missing.")
}
[void]$sb.AppendLine()

Set-Content -Path $outFile -Value $sb.ToString() -Encoding UTF8

# -- Console summary ----------------------------------------------------
if (!$Quiet) {
    Write-Host ""
    Write-Host "Tool inventory -- $stamp" -ForegroundColor Cyan
    foreach ($cat in @('Core','Agents','LaTeX','Numerical','Profiling','Not installed')) {
        $rows = $results | Where-Object { $_.Cat -eq $cat }
        if (!$rows) { continue }
        Write-Host "  $cat" -ForegroundColor DarkYellow
        foreach ($r in $rows) {
            if ($r.Present) {
                $v = if ($r.NoRun) { "present" } else { $r.Version }
                Write-Host ("    {0,-20} {1}" -f $r.Name, $v) -ForegroundColor Gray
            } elseif ($r.Need -eq 'absent') {
                Write-Host ("    {0,-20} not installed (by design)" -f $r.Name) -ForegroundColor DarkGray
            } else {
                Write-Host ("    {0,-20} MISSING ({1})" -f $r.Name, $r.Need) -ForegroundColor Red
            }
        }
    }
    Write-Host ""
    if ($missing) {
        Write-Host "  $($missing.Count) missing. See the Missing section of TOOLS.md." -ForegroundColor Yellow
    } else {
        Write-Host "  Nothing missing." -ForegroundColor Green
    }
    Write-Host "  Written: $outFile"
    Write-Host ""
}
