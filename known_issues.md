# Known platform issues and solutions

This file records environment-specific failures on this machine (Windows 11, DTU OneDrive path).
Updated when new patterns emerge from `_error_log.md`.

---

## 1. Python not available

**Agents affected:** Claude, Codex
**Symptom:** `python3 -c "..."` exits with code 49 — "Python was not found; run without arguments to install from the Microsoft Store"
**Root cause:** Python is not installed; the Windows app execution alias intercepts `python3` and returns 49.
**Solution:** Never use `python3` or `python` for scripting tasks. Use PowerShell instead:
- For byte-level file operations: use the PowerShell tool with `[System.IO.File]::ReadAllBytes()`
- For text processing: use PowerShell string methods or `Get-Content`

---

## 2. Complex PowerShell commands via Bash tool

**Agents affected:** Claude
**Symptom:** Multi-line or variable-heavy PowerShell one-liners fail with parser errors or unexpected output when run via the Bash tool using `pwsh -NoProfile -Command "..."`
**Root cause:** The Bash tool uses a bash-like shell; PowerShell special characters (`$`, backticks, single/double quotes) are interpreted by the outer shell before reaching pwsh.
**Solution:** Use the **PowerShell tool** directly for any non-trivial PS commands. Reserve the Bash tool for simple git commands and helpi calls.

---

## 3. `pwsh -Command` inline script with single quotes

**Agents affected:** Claude
**Symptom:** `pwsh -Command "$fixed = $text -replace '...' "` fails with ParserError — "Expressions are only allowed as the first element of a pipeline"
**Root cause:** Single quotes inside a double-quoted `-Command` string cause PowerShell to misparse the expression.
**Solution:** Either:
- Use the PowerShell tool directly (preferred)
- Use `-EncodedCommand` with a Base64-encoded script (fragile, avoid)
- Write the script to a temp `.ps1` file and call it with `-File`

---

## 4. Curly quotes in PS1 files

**Agents affected:** Claude
**Symptom:** PS1 file written by Edit or Write tool contains `'` / `'` / `"` / `"` (Unicode curly quotes) instead of straight `'` / `"`. Script fails at runtime with unexpected token errors.
**Root cause:** The Write/Edit tools sometimes emit curly quotes from the model's output encoding.
**Solution:** After every Edit or Write to a `.ps1` file, run a byte-level check and fix using the PowerShell tool:
```powershell
$f = '<path>'
$bytes = [System.IO.File]::ReadAllBytes($f)
$text  = [System.Text.Encoding]::UTF8.GetString($bytes)
$fixed = $text -replace [char]0x2018, "'" -replace [char]0x2019, "'" `
               -replace [char]0x201C, '"' -replace [char]0x201D, '"'
if ($fixed -ne $text) { [System.IO.File]::WriteAllText($f, $fixed, [System.Text.Encoding]::UTF8); 'fixed' } else { 'clean' }
```

---

## 5. Paths with spaces in Bash tool

**Agents affected:** Claude, Codex
**Symptom:** Commands involving `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\...` fail because the path contains spaces.
**Root cause:** Bash shell splits on spaces unless paths are quoted.
**Solution:** Always double-quote paths in Bash tool commands. Better: use the PowerShell tool for any operation involving this path.

---

## 6. `pwsh -EncodedCommand` Base64 encoding via Bash

**Agents affected:** Claude
**Symptom:** Base64-encoded command passed to `-EncodedCommand` fails with garbled output or "term not recognized" errors.
**Root cause:** Generating correct UTF-16LE Base64 inline in a Bash command is error-prone; encoding mismatches cause silent corruption.
**Solution:** Never use `-EncodedCommand` generated inline. Write the script to a `.ps1` file and call it with `-File`, or use the PowerShell tool directly.

---

## 7. Codex: Unix-style commands on Windows

**Agents affected:** Codex
**Symptom:** Commands like `ls`, `cat`, `grep`, `sed`, `find` fail or behave unexpectedly.
**Root cause:** Codex sometimes defaults to Unix mental model; this machine runs Windows with PowerShell.
**Solution:** Use PowerShell equivalents: `Get-ChildItem`, `Get-Content`, `Select-String`, `Where-Object`, `Get-ChildItem -Recurse`. Or use `helpi` for infrastructure operations.

---

## Adding new entries

When `_error_log.md` shows a repeating pattern (same error 2+ times), add it here.
Format: symptom → root cause → solution. Keep it short enough to be useful at a glance.
