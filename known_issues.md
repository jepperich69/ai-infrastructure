# Environment map — this machine

Reference document. The compact version of this lives inline in `~/.claude/CLAUDE.md`
and `~/.codex/config.toml`. Update both when new facts are confirmed.

---

## Software inventory

| Tool | Version | Path | In PATH? |
|---|---|---|---|
| PowerShell | 7.6.1 | `C:\Program Files\PowerShell\7\pwsh.exe` | Yes |
| R | 4.5.2 | `C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe` | **No** |
| Python (miniconda) | 3.13.9 | `C:\Users\rich\AppData\Local\miniconda3\python.exe` | **No** |
| conda | — | `C:\Users\rich\AppData\Local\miniconda3\Scripts\conda.exe` | **No** |
| pdflatex / latexmk / xelatex | MiKTeX | `C:\Users\rich\AppData\Local\Programs\MiKTeX\miktex\bin\x64\` | Yes |
| git | 2.54.0 | `C:\Program Files\Git\cmd\git.exe` | Yes |
| gh (GitHub CLI) | 2.88.1 | `C:\Program Files\GitHub CLI\gh.exe` | Yes |
| Node.js | v24.15.0 | `C:\Program Files\nodejs\node.exe` | Yes |
| Stata | — | — | **Not installed** |
| Julia | — | — | **Not installed** |

Conda environments: `base` (default), `pyopt`

---

## Key paths

| Location | Path |
|---|---|
| JR root | `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\` |
| Research projects | `...\JR\Publikationer\` (101 folders, prefix `Pub_` / `Pro_` / `PhD_`) |
| AI infrastructure | `...\JR\AI_auto\` |
| Sensitive data | `...\JR\Sensitive_Data\` — agents must not read or write here |
| R scripts (shared) | `...\JR\Rscripts\` |

---

## Drives

| Drive | Type | Free |
|---|---|---|
| C: | Local disk | ~314 GB |
| M: | Mapped network drive | ~2 GB (nearly full) |
| O: | Large network/SharePoint | Very large |
| U: | Mapped drive | ~65 GB |

---

## Known platform issues

Each entry has a **Status** field:
- `platform-fact` — not fixable in code; agents must route around it permanently
- `fixed (YYYY-MM-DD)` — was broken, now patched; do not revert
- `open` — confirmed bug with a known fix not yet applied; `/catch-up` will handle it

---

### 1. `python3` not available
**Status:** platform-fact
`python3` is a Windows Store alias → exit 49. Use full path:
`C:\Users\rich\AppData\Local\miniconda3\python.exe`

### 2. R not in PATH
**Status:** platform-fact
`R` as a bare command fails. Use full path:
`C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe`

### 3. Complex PowerShell via Bash tool
**Status:** platform-fact
Use the **PowerShell tool** directly. Quoting breaks when running pwsh inside Bash.

### 4. `pwsh -Command` with inline single quotes
**Status:** platform-fact
Single quotes inside `-Command "..."` cause parser errors.
Fix: use the PowerShell tool, or write a `.ps1` file and call with `-File`.

### 5. Curly quotes in PS1 files
**Status:** platform-fact
Write/Edit tools sometimes emit `'` `'` `"` `"`. Check and fix after every `.ps1` edit:
```powershell
$f = '<path>'
$b = [System.IO.File]::ReadAllBytes($f)
$t = [System.Text.Encoding]::UTF8.GetString($b)
$x = $t -replace [char]0x2018,"'" -replace [char]0x2019,"'" -replace [char]0x201C,'"' -replace [char]0x201D,'"'
if ($x -ne $t) { [System.IO.File]::WriteAllText($f,$x,[System.Text.Encoding]::UTF8); 'fixed' } else { 'clean' }
```

### 6. Paths with spaces
**Status:** platform-fact
`OneDrive - Danmarks Tekniske Universitet` contains spaces. Always double-quote paths;
prefer the PowerShell tool for file operations.

### 7. `pwsh -EncodedCommand` inline
**Status:** platform-fact
Fragile — Base64 encoding from Bash corrupts silently. Write a `.ps1` file instead.

### 8. Codex: Unix commands on Windows
**Status:** platform-fact
`ls`, `cat`, `grep`, `find` don't work. Use PowerShell: `Get-ChildItem`, `Get-Content`,
`Select-String`, `Get-ChildItem -Recurse`.

### 9. New project with Overleaf + GitHub: always use `setup_project.ps1`
**Status:** platform-fact

**Wrong pattern (do not repeat):** Create one git repo at the project root with
`origin` = GitHub and `overleaf` = Overleaf as a secondary remote, with
`Overleaf_source/` as a plain subdirectory inside that repo.

Problems this causes:
- `helpi 4` (push_to_overleaf.ps1) runs `git push origin`, so it pushes to GitHub — Overleaf never updates.
- When the full repo IS pushed to Overleaf, it arrives with `main.tex` buried in `Overleaf_source/`, not at the root. Overleaf can't compile it by default.
- Recovery requires a plumbing-level `commit-tree` push because Overleaf blocks force pushes.

**Correct pattern:**
1. `Overleaf_source/` must be its own standalone git repo with `origin` = Overleaf.
   Use the existing tool: `.\setup_project.ps1 -FolderName Pub_X -OverleafUrl https://git.overleaf.com/<id>`
   This clones Overleaf into `Overleaf_source/` correctly and adds it to `projects.json`.
2. If the project also needs a GitHub repo (for code), create a **separate** repo either:
   - In the `code/` subfolder (use `init_project_git.ps1`), or
   - At the project root, with `Overleaf_source/` listed in `.gitignore`.
3. Never add Overleaf as a secondary remote to a repo that already has GitHub as `origin`.

**Rule for Claude:** When setting up a new research project, always run `setup_project.ps1`
for the Overleaf link. Never improvise a dual-remote git setup.

---

### 10. helpi.ps1 crashes in non-interactive shells (PSConsoleReadLine)
**Status:** fixed (2026-05-16)

`helpi.ps1` called `[Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory()` unconditionally.
That class only loads in interactive PowerShell hosts with the PSReadLine module. Non-interactive callers
(Gemini CLI via `! helpi ...`, `powershell.exe -NoProfile`, CI scripts) crash with a hard error at that line.

**Fix:** wrapped in `try { ... } catch {}` -- history is saved when possible, silently skipped otherwise.
The fix is already in `helpi.ps1`; do not revert it.

**Symptom if reverted:** agent reports "cannot run helpi" or PS crashes immediately after the preview line.

---

### 11. Edit/Write tools write UTF-8 BOM — breaks YAML frontmatter and shebangs
**Status:** platform-fact

The Claude Code Edit and Write tools write files with a UTF-8 BOM (`EF BB BF`) on Windows. Any format that requires the file to start at byte 0 with specific content will silently break:
- Codex rejects `SKILL.md` files where `---` is not the literal first bytes — shows "missing YAML frontmatter delimited by ---" even when frontmatter is present.
- Shell scripts with `#!` shebangs will also break.

**Fix (apply after any Edit/Write to a format-sensitive file):**
```powershell
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $text = [System.Text.UTF8Encoding]::new($true).GetString($bytes)
    [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}
```

For batch BOM removal across a directory:
```powershell
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
Get-ChildItem $dir -Recurse -Filter "SKILL.md" | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $text = [System.Text.UTF8Encoding]::new($true).GetString($bytes)
        [System.IO.File]::WriteAllText($_.FullName, $text, $utf8NoBom)
    }
}
```

---

### 12. MiKTeX first-run setup prompt blocks non-interactive latexmk
**Status:** open
**Affects:** Local LaTeX compilation from Codex/non-interactive PowerShell sessions.
**Fix:** Complete MiKTeX's first-run setup for the account used by the non-interactive agent, or run a one-time interactive MiKTeX console/setup before relying on `latexmk` in Codex sessions.

Symptom: `latexmk -pdf ...` exits immediately with "It seems that this is a fresh TeX installation. Please finish the setup before proceeding." Overleaf compilation is unaffected; local compile verification cannot be trusted until the setup prompt is cleared.

---

## Adding new entries

When an issue recurs (2+ times), append a new numbered entry here with:

```
### N. <short title>
**Status:** open
**Affects:** `<file path(s)>`
**Fix:** <exact one-paragraph description of what to change>
<symptom and context>
```

Change status to `fixed (YYYY-MM-DD)` once the fix is applied (by `/catch-up` or manually).
For issues that cannot be fixed in code, use `platform-fact` and omit the **Affects** / **Fix** fields.

Also update the compact block in `~/.claude/CLAUDE.md` and `~/.codex/config.toml` for platform-facts.
