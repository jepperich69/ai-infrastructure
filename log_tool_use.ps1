# log_tool_use.ps1
# PostToolUse hook: appends a timestamped line to _session_draft.md in the project root.
# Only fires for Edit, Write, Bash tools; only in recognised project folders.

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }

try { $data = $raw | ConvertFrom-Json } catch { exit 0 }

$tool = $data.tool_name
if ($tool -notin @('Edit', 'Write', 'Bash')) { exit 0 }

$cwd  = (Get-Location).Path
$base = Split-Path $cwd -Leaf
if ($base -notmatch '^(Pub_|Pro_|PhD_|AI_auto)') { exit 0 }

$ts   = Get-Date -Format 'yyyy-MM-dd HH:mm'
$inp  = $data.tool_input

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
