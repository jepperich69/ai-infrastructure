# runs_watch.ps1 -- read-only monitor of background work on this machine.
#
# Two sources, neither of which touches the jobs themselves:
#   1. A Win32_Process poll: Python, R, PowerShell scripts, Gemini/Codex, LaTeX.
#   2. %LOCALAPPDATA%\AI_runs\events.jsonl, written by the runs_hook.py Claude
#      Code hook: subagents such as /style-edit, /verify-math, /verify-model.
#
# Limits: Windows gives a poller no exit code, so a finished process shows as
# "ended", not success or failure. Processes that end while this window is
# closed are not recorded. Hook events are recorded either way.
#
# The window opens by itself on the first Claude subagent (see runs_hook.py) and
# without taking keyboard focus. It starts small in the bottom-right corner and
# remembers where it is moved and how it is sized (window.json).
#
# With -Files it shows the live file view instead: every file created, changed,
# renamed or deleted under JR, by any agent, script or person (helpi 31). It uses
# a file-system watcher, so it is event-driven, and it records only while open.
# Row 1 is always the latest file; files_index.json holds the numbers shown, and
# open_touched.py uses it to open a file from a prompt such as `open #1`.
#
# Usage: runs_watch.ps1 [-Files] [-Open] [-Once] [-Interval 5] [-Recent 8]
#   -Files show the file view instead of the runs view
#   -Open  open the view in its own Windows Terminal window (helpi 30, helpi 31)
#   -Once  print one snapshot and exit

param(
    [int]$Interval = 5,
    [int]$Recent = 8,
    [switch]$Once,
    [switch]$Open,
    [switch]$Files
)

$ErrorActionPreference = 'Stop'

$Root        = Join-Path $env:LOCALAPPDATA 'AI_runs'
$EventsFile  = Join-Path $Root 'events.jsonl'
$HistoryFile = Join-Path $Root 'history.jsonl'
$AliveFile   = Join-Path $Root 'window.alive'
$ClaimFile   = Join-Path $Root 'window.claim'
$Title       = if ($Files) { 'Files' } else { 'Runs' }
$WindowFile  = Join-Path $Root $(if ($Files) { 'files_window.json' } else { 'window.json' })
$TouchedFile = Join-Path $Root 'files.jsonl'
$IndexFile   = Join-Path $Root 'files_index.json'
$WatchRoot   = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

$MinLiveAge   = 5              # seconds; hides hooks and other short helpers
$MinRecentAge = 30             # seconds; shorter jobs are left out of RECENT
$QuietAfter   = 20 * 60        # agent transcript idle this long: "quiet"
$LostAfter    = 2 * 3600       # agent transcript idle this long: "lost"
$RecentWindow = 24 * 3600
$TailBytes    = 1MB            # registry files are read from their tail only

$ProcNames = @(
    'python.exe', 'pythonw.exe', 'Rscript.exe', 'Rterm.exe', 'pwsh.exe',
    'powershell.exe', 'node.exe', 'gemini.exe', 'codex.exe', 'claude.exe',
    'pdflatex.exe', 'lualatex.exe', 'xelatex.exe', 'latexmk.exe', 'biber.exe'
)
$ProcFilter = ($ProcNames | ForEach-Object { "Name='$_'" }) -join ' OR '

# Infrastructure helpers and always-on daemons, which are not runs.
$IgnoreCmd = 'runs_watch\.ps1|runs_hook\.py|log_tool_use\.ps1|sync_claude_config\.ps1|' +
             'session_prompt_logger\.py|session_prompts_convert\.py|' +
             'notetaker_watcher\.ps1|backup_daemon\.ps1'
$WorkerCmd = 'multiprocessing|joblib|loky'

# Skipped by the file view: tool internals, LaTeX by-products, editor temp files.
$FileNoise = '\\\.git\\|\\__pycache__\\|\\node_modules\\|\\\.venv\\|\\\.Rproj\.user\\|' +
             '\\\.ipynb_checkpoints\\|\\\.pytest_cache\\|\\_claude_backup\\|\\Sensitive_Data\\|' +
             '~\$|\.~lock|\.tmp(\.\w+)?$|\.temp$|\.crdownload$|desktop\.ini$|\.pyc$|\.Rhistory$|' +
             '_session_draft\.md$|\\session-prompts\\|\\NoteTaker\\runtime\\|\.run\.xml$|\.synctex(\.gz|\(busy\))?$|' +
             '\.(aux|bbl|blg|bcf|fdb_latexmk|fls|lof|lot|nav|snm|toc|vrb)$'

function Get-Now { [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() / 1000.0 }

function Test-Monitor([string]$CommandLine, [bool]$FileView) {
    if ($CommandLine -notmatch 'runs_watch\.ps1' -or $CommandLine -match '\s-Open') { return $false }
    return ($CommandLine -match '\s-Files') -eq $FileView
}

function Start-View([bool]$FileView) {
    $mode = if ($FileView) { ' -Files' } else { '' }
    $size = if ($FileView) { '90,14' } else { '72,12' }
    $pwshArgs = "-NoLogo -NoProfile -File `"$PSCommandPath`"$mode"
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        # Always a new window, so a dead one cannot swallow the size setting.
        Start-Process wt -WindowStyle Minimized -ArgumentList "--size $size -w new nt pwsh $pwshArgs"
    } else {
        Start-Process pwsh -ArgumentList $pwshArgs
    }
}

# Opening the runs view also opens the file view. A file view closed by hand while
# the runs view stays open is left closed.
function Open-Monitor {
    $lines = (Get-CimInstance Win32_Process -Filter "Name='pwsh.exe'").CommandLine
    if ($lines | Where-Object { Test-Monitor $_ ([bool]$Files) }) {
        Write-Host "The $($Title.ToLower()) window is already open."
        return
    }
    Start-View ([bool]$Files)
    if (!$Files -and !($lines | Where-Object { Test-Monitor $_ $true })) {
        # One at a time, so each hands focus back before the next one takes it.
        Start-Sleep -Seconds 3
        Start-View $true
    }
}

function Initialize-WindowApi {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class RunsWin {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct MONITORINFO {
        public int cbSize; public RECT rcMonitor; public RECT rcWork; public uint dwFlags;
    }
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern IntPtr FindWindow(string cls, string title);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern IntPtr MonitorFromWindow(IntPtr h, uint flags);
    [DllImport("user32.dll")] public static extern IntPtr MonitorFromRect(ref RECT r, uint flags);
    [DllImport("user32.dll")] public static extern bool GetMonitorInfo(IntPtr m, ref MONITORINFO i);
    [DllImport("user32.dll")] public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr c);
    public static void UsePhysicalPixels() { SetThreadDpiAwarenessContext(new IntPtr(-4)); }
    public static RECT WorkArea(IntPtr h) {
        MONITORINFO i = new MONITORINFO();
        i.cbSize = Marshal.SizeOf(typeof(MONITORINFO));
        GetMonitorInfo(MonitorFromWindow(h, 2), ref i);
        return i.rcWork;
    }
}
'@
}

# Find this window, put it where it was last left, and show it without activating it.
function Restore-Window {
    $script:Hwnd = [IntPtr]::Zero
    # A unique title finds this window, not one left over from an earlier run.
    $uniqueTitle = "$Title $PID"
    $Host.UI.RawUI.WindowTitle = $uniqueTitle
    try {
        Initialize-WindowApi
        [RunsWin]::UsePhysicalPixels()
        foreach ($try in 1..30) {
            $script:Hwnd = [RunsWin]::FindWindow('CASCADIA_HOSTING_WINDOW_CLASS', $uniqueTitle)
            if ($script:Hwnd -ne [IntPtr]::Zero) { break }
            Start-Sleep -Milliseconds 100
        }
        $Host.UI.RawUI.WindowTitle = $Title
        if ($script:Hwnd -eq [IntPtr]::Zero) { return }

        $rect = New-Object RunsWin+RECT
        [void][RunsWin]::GetWindowRect($script:Hwnd, [ref]$rect)
        $w = $rect.Right - $rect.Left
        $h = $rect.Bottom - $rect.Top
        $work = [RunsWin]::WorkArea($script:Hwnd)
        $x = $work.Right - $w - 8
        $y = $work.Bottom - $h - 8
        # The file view starts just above where the runs view starts.
        if ($Files) { $y = [Math]::Max($work.Top, $y - 460) }

        if (Test-Path -LiteralPath $WindowFile) {
            $saved = Get-Content -LiteralPath $WindowFile -Raw | ConvertFrom-Json
            $target = New-Object RunsWin+RECT
            $target.Left = $saved.x; $target.Top = $saved.y
            $target.Right = $saved.x + $saved.w; $target.Bottom = $saved.y + $saved.h
            # A monitor that has since been unplugged falls back to the corner.
            if ([RunsWin]::MonitorFromRect([ref]$target, 0) -ne [IntPtr]::Zero) {
                $x = $saved.x; $y = $saved.y; $w = $saved.w; $h = $saved.h
            }
        }
        # Windows Terminal activates itself on launch. Minimizing hands focus back to
        # the previous window; 6 = SW_MINIMIZE, 4 = SW_SHOWNOACTIVATE.
        if ([RunsWin]::GetForegroundWindow() -eq $script:Hwnd) { [void][RunsWin]::ShowWindow($script:Hwnd, 6) }
        [void][RunsWin]::ShowWindow($script:Hwnd, 4)
        # The file view opens second, so minimizing it can land focus on the runs view.
        $runs = [RunsWin]::FindWindow('CASCADIA_HOSTING_WINDOW_CLASS', 'Runs')
        if ($Files -and $runs -ne [IntPtr]::Zero -and [RunsWin]::GetForegroundWindow() -eq $runs) {
            [void][RunsWin]::ShowWindow($runs, 6)
            [void][RunsWin]::ShowWindow($runs, 4)
        }
        [void][RunsWin]::SetWindowPos($script:Hwnd, [IntPtr]::Zero, $x, $y, $w, $h, 0x14)
    } catch {
        $script:Hwnd = [IntPtr]::Zero
    }
}

function Save-Window {
    if ($script:Hwnd -eq [IntPtr]::Zero -or [RunsWin]::IsIconic($script:Hwnd)) { return }
    $r = New-Object RunsWin+RECT
    if (![RunsWin]::GetWindowRect($script:Hwnd, [ref]$r)) { return }
    $state = "$($r.Left),$($r.Top),$($r.Right),$($r.Bottom)"
    if ($state -eq $script:SavedState) { return }
    $script:SavedState = $state
    @{ x = $r.Left; y = $r.Top; w = $r.Right - $r.Left; h = $r.Bottom - $r.Top } |
        ConvertTo-Json -Compress | Set-Content -LiteralPath $WindowFile -Encoding utf8
}

function Get-FileName([string]$Cmd, [string]$Ext) {
    $m = [regex]::Match($Cmd, '"([^"]+\.' + $Ext + ')"|(?:^|\s)([^\s"]+\.' + $Ext + ')(?=\s|$)',
        [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (!$m.Success) { return $null }
    $value = if ($m.Groups[1].Success) { $m.Groups[1].Value } else { $m.Groups[2].Value }
    return ($value -split '[\\/]')[-1]
}

# Returns @{Kind; Job} for a process worth listing, or $null.
function Get-Job([string]$Name, [string]$Cmd) {
    if ($Cmd -match $IgnoreCmd) { return $null }
    switch -Regex ($Name) {
        '^python' {
            $job = Get-FileName $Cmd 'py'
            if (!$job -and $Cmd -match '\s-m\s+(\S+)') { $job = "-m $($Matches[1])" }
            if (!$job) { $job = 'python (inline)' }
            return @{ Kind = 'python'; Job = $job }
        }
        '^(Rscript|Rterm)' {
            $job = if ($Cmd -match '--file=("[^"]+"|\S+)') { ($Matches[1].Trim('"') -split '[\\/]')[-1] }
                   else { Get-FileName $Cmd 'R' }
            if (!$job) { $job = 'R session' }
            return @{ Kind = 'R'; Job = $job }
        }
        '^(pwsh|powershell)' {
            if ($Cmd -notmatch '-File') { return $null }
            $job = Get-FileName $Cmd 'ps1'
            if (!$job) { return $null }
            return @{ Kind = 'ps1'; Job = $job }
        }
        '^node' {
            if ($Cmd -match 'gemini') { return @{ Kind = 'agent'; Job = 'gemini' } }
            if ($Cmd -match 'codex')  { return @{ Kind = 'agent'; Job = 'codex' } }
            return $null
        }
        '^(gemini|codex)' { return @{ Kind = 'agent'; Job = $Name -replace '\.exe$' } }
        '^claude'         { return @{ Kind = 'session'; Job = 'claude' } }
        default {
            $job = Get-FileName $Cmd 'tex'
            if (!$job) { $job = $Name -replace '\.exe$' }
            return @{ Kind = 'latex'; Job = $job }
        }
    }
}

function Get-ProjectName([string]$Text) {
    if ($Text -match '[\\/]JR[\\/](?:Publikationer[\\/])?([^\\/"]+)') { return $Matches[1] }
    return '-'
}

function Get-LogName([string]$Text) {
    $pattern = '(?:>>?|Tee-Object\s+(?:-FilePath\s+)?)\s*"?([^"\s|&;>]+\.(?:log|out|txt))'
    if ($Text -match $pattern) { return ($Matches[1] -split '[\\/]')[-1] }
    return $null
}

# Reads the end of a registry file; the writer may be appending, so share it.
function Read-Tail([string]$Path, [long]$Offset, [ref]$NewOffset) {
    if (!(Test-Path -LiteralPath $Path)) { $NewOffset.Value = 0; return @() }
    $stream = [IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite,Delete')
    try {
        $partial = $false
        if ($Offset -lt 0) {
            $start = [Math]::Max(0, $stream.Length - $TailBytes)
            $partial = $start -gt 0
        } else {
            $start = $Offset
        }
        $stream.Position = $start
        $count = [int]($stream.Length - $start)
        if ($count -le 0) { $NewOffset.Value = $start; return @() }
        $buffer = New-Object byte[] $count
        $read = $stream.Read($buffer, 0, $count)
        $text = [Text.Encoding]::UTF8.GetString($buffer, 0, $read)
        # Keep an unfinished last line for the next poll.
        $end = $text.LastIndexOf("`n")
        if ($end -lt 0) { $NewOffset.Value = $start; return @() }
        $NewOffset.Value = $start + [Text.Encoding]::UTF8.GetByteCount($text.Substring(0, $end + 1))
        $lines = $text.Substring(0, $end) -split "`r?`n"
        if ($partial) { $lines = $lines | Select-Object -Skip 1 }
        return $lines
    } finally {
        $stream.Dispose()
    }
}

function Update-Agents {
    $next = 0L
    $lines = Read-Tail $EventsFile $script:EventsOffset ([ref]$next)
    $script:EventsOffset = $next
    foreach ($line in $lines) {
        if (!$line) { continue }
        try { $e = $line | ConvertFrom-Json } catch { continue }
        if (!$e.agent_id) { continue }
        $a = $script:Agents[$e.agent_id]
        if (!$a) {
            $a = @{ Id = $e.agent_id; Start = $e.ts; Stop = $null; Job = $null; Type = $e.agent_type
                    Session = $e.session; Cwd = $e.cwd; Heartbeat = $null }
            $script:Agents[$e.agent_id] = $a
        }
        switch ($e.event) {
            # A resumed agent starts again under the same id.
            'SubagentStart' { if ($a.Stop) { $a.Stop = $null; $a.Start = $e.ts } }
            # Fires more than once per agent; the latest time wins.
            'SubagentStop'  { $a.Stop = $e.ts }
            'PostToolUse'   { if ($e.description) { $a.Job = $e.description } }
        }
    }
}

function Get-AgentTranscript($Agent) {
    if (!$Agent.Cwd -or !$Agent.Session) { return $null }
    $slug = $Agent.Cwd -replace '[^A-Za-z0-9]', '-'
    return Join-Path $HOME ".claude\projects\$slug\$($Agent.Session)\subagents\agent-$($Agent.Id).jsonl"
}

function Get-AgentRows([double]$Now) {
    $active = @(); $finished = @()
    foreach ($a in @($script:Agents.Values)) {
        $job = if ($a.Job) { $a.Job } else { $a.Type }
        $project = Get-ProjectName ($a.Cwd + '\')
        if ($a.Stop) {
            if (($a.Stop - $a.Start) -ge $MinRecentAge) {
                $finished += @{ State = 'done'; Kind = 'claude'; Job = $job; Project = $project
                                Start = $a.Start; End = $a.Stop }
            }
            continue
        }
        $last = $a.Start
        $path = Get-AgentTranscript $a
        if ($path -and (Test-Path -LiteralPath $path)) {
            $last = [Math]::Max($last, ([DateTimeOffset](Get-Item -LiteralPath $path).LastWriteTimeUtc).ToUnixTimeSeconds())
        }
        $idle = $Now - $last
        if ($idle -ge $LostAfter) {
            $finished += @{ State = 'lost'; Kind = 'claude'; Job = $job; Project = $project
                            Start = $a.Start; End = $last }
        } else {
            $state = if ($idle -ge $QuietAfter) { 'quiet' } else { 'running' }
            $active += @{ State = $state; Kind = 'claude'; Job = $job; Project = $project
                          Age = $Now - $a.Start; Cpu = $null; Mem = $null; ProcessId = $null }
        }
    }
    return @{ Active = $active; Finished = $finished }
}

function Get-ProcessRows([double]$Now) {
    $wall = $Now - $script:LastPoll
    $items = @{}
    foreach ($p in Get-CimInstance Win32_Process -Filter $ProcFilter) {
        $cmd = [string]$p.CommandLine
        $job = Get-Job $p.Name $cmd
        if (!$job) { continue }
        $key = "$($p.ProcessId)|$($p.CreationDate.Ticks)"
        $ticks = [double]$p.KernelModeTime + [double]$p.UserModeTime
        $cpu = $null
        if ($script:CpuTicks.ContainsKey($key) -and $wall -gt 0) {
            $cpu = 100 * ($ticks - $script:CpuTicks[$key]) / 1e7 / $wall
        }
        $items[[int]$p.ProcessId] = @{
            Pid = [int]$p.ProcessId; Parent = [int]$p.ParentProcessId; Key = $key; Cmd = $cmd
            Kind = $job.Kind; Job = $job.Job; Ticks = $ticks; Cpu = $cpu; Mem = [double]$p.WorkingSetSize
            Start = ([DateTimeOffset]$p.CreationDate).ToUnixTimeSeconds(); Workers = 0
        }
    }

    # Fold workers and venv launcher children into the job that started them.
    $roots = @{}
    foreach ($item in $items.Values) {
        $cur = $item
        while ($true) {
            $up = $items[$cur.Parent]
            if (!$up -or $up.Kind -ne $cur.Kind -or $up.Start -gt $cur.Start) { break }
            if ($up.Job -ne $cur.Job -and $cur.Cmd -notmatch $WorkerCmd) { break }
            $cur = $up
        }
        if ($cur.Pid -eq $item.Pid) {
            $roots[$item.Pid] = $item
        } else {
            $cur.Workers++
            $cur.Mem += $item.Mem
            if ($null -ne $item.Cpu) { $cur.Cpu = [double]$cur.Cpu + $item.Cpu }
        }
    }

    $ticksNow = @{}
    foreach ($item in $items.Values) { $ticksNow[$item.Key] = $item.Ticks }
    $script:CpuTicks = $ticksNow
    $script:LastPoll = $Now

    $sessions = 0
    $rows = @()
    $seenNow = @{}
    foreach ($r in $roots.Values) {
        if ($r.Kind -eq 'session') { $sessions++; continue }
        $age = $Now - $r.Start
        if ($age -lt $MinLiveAge) { continue }
        $seenNow[$r.Key] = $true
        $known = $script:Known[$r.Key]
        if (!$known) {
            # Project and log are often visible only in the launching shell.
            $text = $r.Cmd
            try {
                $parent = Get-CimInstance Win32_Process -Filter "ProcessId=$($r.Parent)"
                if ($parent) { $text = "$text $($parent.CommandLine)" }
            } catch { }
            $job = $r.Job
            $log = Get-LogName $text
            if ($log) { $job = "$job > $log" }
            $known = @{ Kind = $r.Kind; Job = $job; Project = (Get-ProjectName $text); Start = $r.Start }
            $script:Known[$r.Key] = $known
        }
        $known.Seen = $Now
        $label = if ($r.Workers) { "$($known.Job) (+$($r.Workers))" } else { $known.Job }
        $rows += @{ State = 'running'; Kind = $r.Kind; Job = $label; Project = $known.Project
                    Age = $age; Cpu = $r.Cpu; Mem = $r.Mem; ProcessId = $r.Pid }
    }

    foreach ($key in @($script:Known.Keys)) {
        if ($seenNow[$key]) { continue }
        $gone = $script:Known[$key]
        $script:Known.Remove($key)
        if (($gone.Seen - $gone.Start) -lt $MinRecentAge) { continue }
        $entry = [ordered]@{ state = 'ended'; kind = $gone.Kind; job = $gone.Job; project = $gone.Project
                             start = $gone.Start; end = $gone.Seen }
        Add-Content -LiteralPath $HistoryFile -Value ($entry | ConvertTo-Json -Compress) -Encoding utf8
    }
    return @{ Rows = $rows; Sessions = $sessions }
}

function Get-HistoryRows([double]$Now) {
    $next = 0L
    foreach ($line in (Read-Tail $HistoryFile $script:HistoryOffset ([ref]$next))) {
        if (!$line) { continue }
        try { $h = $line | ConvertFrom-Json } catch { continue }
        $script:History += @{ State = $h.state; Kind = $h.kind; Job = $h.job; Project = $h.project
                              Start = $h.start; End = $h.end }
    }
    $script:HistoryOffset = $next
    $script:History = @($script:History | Where-Object { ($Now - $_.End) -lt $RecentWindow })
    return $script:History
}

function Format-Span([double]$Seconds) {
    $s = [int][Math]::Max(0, $Seconds)
    if ($s -lt 90)    { return "${s}s" }
    if ($s -lt 3600)  { return "$([int]($s / 60))m" }
    if ($s -lt 86400) { return '{0}h{1:00}' -f [Math]::Floor($s / 3600), [Math]::Floor(($s % 3600) / 60) }
    return '{0}d{1:00}h' -f [Math]::Floor($s / 86400), [Math]::Floor(($s % 86400) / 3600)
}

function Format-Cell([string]$Text, [int]$Width) {
    if ($Text.Length -gt $Width) { return $Text.Substring(0, $Width - 2) + '..' }
    return $Text.PadRight($Width)
}

function Get-Screen([double]$Now) {
    Update-Agents
    $proc = Get-ProcessRows $Now
    $agents = Get-AgentRows $Now
    $history = Get-HistoryRows $Now

    $width = 110; $height = 50
    try {
        $width = [Math]::Max(40, [Console]::WindowWidth - 1)
        if (!$Once) { $height = [Math]::Max(6, [Console]::WindowHeight) }
    } catch { }
    $compact = $width -lt 100
    $projectWidth = if ($compact) { 14 } else { 20 }
    $used = if ($compact) { 8 + $projectWidth + 1 + 6 + 5 } else { 8 + 8 + $projectWidth + 1 + 6 + 7 + 7 + 8 }
    $jobWidth = [Math]::Max(8, $width - $used)

    $row = {
        param($r, $time, $tail)
        $project = if ($compact) { $r.Project -replace '^(Pub|Pro|PhD)_' } else { $r.Project }
        $line = Format-Cell $r.State 8
        if (!$compact) { $line += Format-Cell $r.Kind 8 }
        return $line + (Format-Cell $project $projectWidth) + (Format-Cell $r.Job $jobWidth) + ' ' +
               $time.PadLeft(6) + $tail
    }
    $color = @{ running = 32; quiet = 33; ended = 90; done = 90; lost = 31 }
    $out = New-Object Collections.Generic.List[string]
    $paint = {
        param($text, $state)
        if ($Once) { $out.Add($text) }
        else { $out.Add("$([char]27)[$($color[$state])m$text$([char]27)[0m") }
    }

    $clock = (Get-Date).ToString('HH:mm:ss')
    $out.Add("RUNS  $clock   Claude sessions: $($proc.Sessions)")
    if (!$compact) { $out.Add('') }
    $headRow = @{ State = 'STATE'; Kind = 'KIND'; Project = 'PROJECT'; Job = 'JOB' }
    $headTail = if ($compact) { 'CPU'.PadLeft(5) } else { 'CPU%'.PadLeft(7) + 'MEM'.PadLeft(7) + 'PID'.PadLeft(8) }
    $out.Add((& $row $headRow 'TIME' $headTail))

    # The list must fit the window: a scrolling screen would break the redraw.
    $active = @(@($proc.Rows) + @($agents.Active) | Where-Object { $_ } | Sort-Object { $_.Age })
    $maxActive = [Math]::Max(2, $height - $out.Count - 1)
    $hidden = 0
    if ($active.Count -gt $maxActive) {
        $hidden = $active.Count - ($maxActive - 1)
        $active = @($active | Select-Object -Last ($maxActive - 1))
    }
    if (!$active) { $out.Add('(nothing running)') }
    foreach ($r in $active) {
        $cpu = if ($null -ne $r.Cpu) { '{0:0}' -f $r.Cpu } else { '' }
        $mem = if ($r.Mem) { '{0:0.0}G' -f ($r.Mem / 1GB) } else { '' }
        $tail = if ($compact) { $cpu.PadLeft(5) } else { $cpu.PadLeft(7) + $mem.PadLeft(7) + ([string]$r.ProcessId).PadLeft(8) }
        & $paint (& $row $r (Format-Span $r.Age) $tail) $r.State
    }
    if ($hidden) { $out.Add("+$hidden newer jobs hidden; enlarge the window") }

    if (!$compact) { $out.Add('') }
    $slots = [Math]::Min($Recent, $height - $out.Count - 2)
    if ($slots -ge 1) {
        $finished = @($history) + @($agents.Finished) |
            Where-Object { $_ -and ($Now - $_.End) -lt $RecentWindow } |
            Sort-Object { $_.End } -Descending | Select-Object -First $slots
        $out.Add('RECENT (24h)')
        if (!$finished) { $out.Add('(none)') }
        foreach ($r in $finished) {
            $when = ([DateTimeOffset]::FromUnixTimeSeconds([long]$r.End)).LocalDateTime.ToString('HH:mm')
            $tail = if ($compact) { " $when" } else { "  ended $when" }
            & $paint (& $row $r (Format-Span ($r.End - $r.Start)) $tail) $r.State
        }
    }
    return $out
}

function Initialize-FileFeed {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.IO;
using System.Text.RegularExpressions;
using System.Threading;
public class FileFeed {
    public ConcurrentQueue<string[]> Queue = new ConcurrentQueue<string[]>();
    public int Missed;
    private FileSystemWatcher watcher;
    private Regex noise;
    public FileFeed(string path, string noisePattern) {
        noise = new Regex(noisePattern, RegexOptions.IgnoreCase | RegexOptions.Compiled);
        watcher = new FileSystemWatcher(path);
        watcher.IncludeSubdirectories = true;
        watcher.InternalBufferSize = 65536;
        watcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite | NotifyFilters.Size;
        watcher.Changed += (s, e) => Add("M", e.FullPath);
        watcher.Created += (s, e) => Add("A", e.FullPath);
        watcher.Deleted += (s, e) => Add("D", e.FullPath);
        watcher.Renamed += (s, e) => Add("M", e.FullPath);
        watcher.Error += (s, e) => Interlocked.Increment(ref Missed);
        watcher.EnableRaisingEvents = true;
    }
    private void Add(string kind, string path) {
        if (noise.IsMatch(path)) return;
        Queue.Enqueue(new string[] { kind, path });
    }
}
'@
}

function Add-Touched($Kind, $Path, $When, [int]$Count = 1) {
    $row = $script:Touched[$Path]
    if (!$row) {
        $row = @{ Path = $Path; Kind = $Kind; When = $When; Count = 0; Logged = 0 }
        $script:Touched[$Path] = $row
    } elseif ($Kind -eq 'D' -or $row.Kind -eq 'D') {
        $row.Kind = $Kind
    }
    $row.When = $When
    $row.Count += $Count
    return $row
}

function Get-TouchedLines([double]$Now) {
    $item = $null
    $missed = $script:Feed.Missed
    while ($script:Feed.Queue.TryDequeue([ref]$item)) {
        if ($item[0] -ne 'D' -and [IO.Directory]::Exists($item[1])) { continue }
        $row = Add-Touched $item[0] $item[1] $Now
        # Files such as job logs change constantly; one line a minute is enough.
        if ($item[0] -eq 'D' -or ($Now - $row.Logged) -ge 60) {
            $row.Logged = $Now
            $entry = [ordered]@{ ts = $Now; kind = $row.Kind; path = $row.Path }
            Add-Content -LiteralPath $TouchedFile -Value ($entry | ConvertTo-Json -Compress) -Encoding utf8
        }
    }
    foreach ($key in @($script:Touched.Keys)) {
        if (($Now - $script:Touched[$key].When) -ge $RecentWindow) { $script:Touched.Remove($key) }
    }

    $width = 110; $height = 40
    try {
        $width = [Math]::Max(40, [Console]::WindowWidth - 1)
        if (!$Once) { $height = [Math]::Max(4, [Console]::WindowHeight) }
    } catch { }

    $out = New-Object Collections.Generic.List[string]
    $note = if ($missed) { '   SOME EVENTS MISSED' } else { '' }
    $out.Add("FILES   last 24h: $($script:Touched.Count) files under JR$note")
    $projectWidth = 18
    $pathWidth = [Math]::Max(10, $width - 4 - 9 - 2 - $projectWidth - 1)
    $sorted = @($script:Touched.Values | Sort-Object { $_.When } -Descending)
    if (!$Once) {
        # Written with the screen, so a number always means what the window shows.
        $paths = @($sorted | Select-Object -First 500 | ForEach-Object { $_.Path })
        $temp = "$IndexFile.tmp"
        [IO.File]::WriteAllText($temp, (ConvertTo-Json -InputObject $paths -Compress))
        [IO.File]::Move($temp, $IndexFile, $true)
    }
    if (!$sorted) { $out.Add('(no changes yet)') }
    $number = 0
    foreach ($r in ($sorted | Select-Object -First ($height - 1))) {
        $number++
        $project = Get-ProjectName $r.Path
        $relative = $r.Path
        $mark = $relative.IndexOf("\$project\")
        if ($mark -ge 0) { $relative = $relative.Substring($mark + $project.Length + 2) }
        elseif ($relative.StartsWith($WatchRoot)) { $relative = $relative.Substring($WatchRoot.Length + 1) }
        if ($r.Count -gt 1) { $relative += " x$($r.Count)" }
        if ($relative.Length -gt $pathWidth) {
            $relative = '..' + $relative.Substring($relative.Length - $pathWidth + 2)
        }
        $when = ([DateTimeOffset]::FromUnixTimeSeconds([long]$r.When)).LocalDateTime.ToString('HH:mm:ss')
        $line = "$(([string]$number).PadLeft(3)) $when $($r.Kind) " + (Format-Cell ($project -replace '^(Pub|Pro|PhD)_') $projectWidth) + ' ' + $relative
        if ($Once) { $out.Add($line) }
        else {
            # Green for the last minute, red for deletions, grey once it has settled.
            $code = if ($r.Kind -eq 'D') { 31 } elseif (($Now - $r.When) -lt 60) { 32 } else { 90 }
            $out.Add("$([char]27)[${code}m$line$([char]27)[0m")
        }
    }
    return $out
}

function Start-FileView {
    $script:Touched = @{}
    foreach ($line in (Read-Tail $TouchedFile -1L ([ref]$script:HistoryOffset))) {
        if (!$line) { continue }
        try { $e = $line | ConvertFrom-Json } catch { continue }
        if (((Get-Now) - $e.ts) -lt $RecentWindow) { $null = Add-Touched $e.kind $e.path $e.ts 1 }
    }
    Initialize-FileFeed
    $script:Feed = New-Object FileFeed $WatchRoot, $FileNoise
}

# ---------------------------------------------------------------------------

if ($Open) { Open-Monitor; return }

if (!(Test-Path -LiteralPath $Root)) { New-Item -ItemType Directory -Path $Root -Force | Out-Null }

$script:Agents = @{}
$script:Known = @{}
$script:CpuTicks = @{}
$script:History = @()
$script:EventsOffset = -1L
$script:HistoryOffset = -1L
$script:LastPoll = Get-Now

if ($Files -and $Once) {
    Start-FileView
    Start-Sleep -Seconds 1
    Get-TouchedLines (Get-Now)
    return
}

if ($Once) {
    # Two polls one second apart, so CPU figures are filled in.
    $null = Get-Screen (Get-Now)
    Start-Sleep -Seconds 1
    Get-Screen (Get-Now)
    return
}

(Get-Process -Id $PID).PriorityClass = 'BelowNormal'
$script:SavedState = ''
Restore-Window
if ($Files) {
    Start-FileView
    $Interval = [Math]::Min($Interval, 2)
} else {
    # In this order, so no subagent sees neither marker and opens a second window.
    [IO.File]::WriteAllText($AliveFile, '')
    Remove-Item -LiteralPath $ClaimFile -ErrorAction SilentlyContinue
}
$esc = [char]27
[Console]::Write("$esc[?25l$esc[2J")
try {
    $lastDraw = 0
    while ($true) {
        # The file view is event-driven: between changes it redraws only to fade colours.
        if ($Files -and $script:Feed.Queue.IsEmpty -and ((Get-Now) - $lastDraw) -lt 30) {
            Save-Window
            Start-Sleep -Seconds $Interval
            continue
        }
        $lastDraw = Get-Now
        $lines = if ($Files) { Get-TouchedLines (Get-Now) } else { Get-Screen (Get-Now) }
        $body = ($lines | ForEach-Object { "$_$esc[K" }) -join "`n"
        [Console]::Write("$esc[H$body$esc[J")
        if (!$Files) { [IO.File]::WriteAllText($AliveFile, '') }
        Save-Window
        Start-Sleep -Seconds $Interval
    }
} finally {
    [Console]::Write("$esc[?25h")
}
