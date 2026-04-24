# log_tool_use.ps1
# PostToolUse hook: appends a timestamped line to _session_draft.md in the project root.
# Also logs Bash errors to AI_auto/_error_log.md for pattern analysis.
# Only fires for Edit, Write, Bash tools; only in recognised project folders.

param(
    [string]$Agent = 'Claude'
)

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }

try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$tool = $data.tool_name
if ($tool -notin @('Edit', 'Write', 'Bash')) { exit 0 }

$cwd  = (Get-Location).Path
$base = Split-Path $cwd -Leaf
if ($base -notmatch '^(Pub_|Pro_|PhD_|AI_auto)') { exit 0 }

$ts  = Get-Date -Format 'yyyy-MM-dd HH:mm'
$inp = $data.tool_input

# ---------------------------------------------------------------
# Session draft (what happened)
# ---------------------------------------------------------------
$line = switch ($tool) {
    'Edit'  {
        $f = $inp.file_path -replace [regex]::Escape($cwd + '\'), '' `
                            -replace [regex]::Escape($cwd + '/'),  ''
        "[$ts] Edit:  $f"
    }
    'Write' {
        $f = $inp.file_path -replace [regex]::Escape($cwd + '\'), '' `
                            -replace [regex]::Escape($cwd + '/'),  ''
        "[$ts] Write: $f"
    }
    'Bash'  {
        $cmd = ($inp.command -replace '\s+', ' ').Trim()
        if ($cmd.Length -gt 100) { $cmd = $cmd.Substring(0, 100) + '...' }
        "[$ts] Bash:  $cmd"
    }
}

if ($line) {
    Add-Content -Path (Join-Path $cwd '_session_draft.md') -Value $line -Encoding UTF8
}

# ---------------------------------------------------------------
# Error log (Bash failures only)
# ---------------------------------------------------------------
if ($tool -eq 'Bash') {
    $resp = $data.tool_response
    $respText = if ($resp -is [string]) { $resp } else { $resp | ConvertTo-Json -Depth 3 }

    $isError = $respText -match 'Exit code [1-9]' -or
               $respText -match '"is_error"\s*:\s*true' -or
               $respText -match 'not recognized' -or
               $respText -match 'was not found' -or
               $respText -match 'ParserError' -or
               $respText -match 'CommandNotFoundException'

    if ($isError) {
        $cmd = ($inp.command -replace '\s+', ' ').Trim()
        if ($cmd.Length -gt 120) { $cmd = $cmd.Substring(0, 120) + '...' }

        # First line of error response
        $errLine = ($respText -split "`n" | Where-Object { $_.Trim() } | Select-Object -First 1).Trim()
        if ($errLine.Length -gt 120) { $errLine = $errLine.Substring(0, 120) + '...' }

        $errorEntry = "[$ts] Agent: $Agent | Project: $base | Tool: Bash | Error: $errLine | Command: $cmd"
        $errorLogPath = Join-Path $PSScriptRoot '_error_log.md'
        Add-Content -Path $errorLogPath -Value $errorEntry -Encoding UTF8
    }
}
