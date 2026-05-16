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

### 1. `python3` not available
`python3` is a Windows Store alias → exit 49. Use full path:
`C:\Users\rich\AppData\Local\miniconda3\python.exe`

### 2. R not in PATH
`R` as a bare command fails. Use full path:
`C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe`

### 3. Complex PowerShell via Bash tool
Use the **PowerShell tool** directly. Quoting breaks when running pwsh inside Bash.

### 4. `pwsh -Command` with inline single quotes
Single quotes inside `-Command "..."` cause parser errors.
Fix: use the PowerShell tool, or write a `.ps1` file and call with `-File`.

### 5. Curly quotes in PS1 files
Write/Edit tools sometimes emit `'` `'` `"` `"`. Check and fix after every `.ps1` edit:
```powershell
$f = '<path>'
$b = [System.IO.File]::ReadAllBytes($f)
$t = [System.Text.Encoding]::UTF8.GetString($b)
$x = $t -replace [char]0x2018,"'" -replace [char]0x2019,"'" -replace [char]0x201C,'"' -replace [char]0x201D,'"'
if ($x -ne $t) { [System.IO.File]::WriteAllText($f,$x,[System.Text.Encoding]::UTF8); 'fixed' } else { 'clean' }
```

### 6. Paths with spaces
`OneDrive - Danmarks Tekniske Universitet` contains spaces. Always double-quote paths;
prefer the PowerShell tool for file operations.

### 7. `pwsh -EncodedCommand` inline
Fragile — Base64 encoding from Bash corrupts silently. Write a `.ps1` file instead.

### 8. Codex: Unix commands on Windows
`ls`, `cat`, `grep`, `find` don't work. Use PowerShell: `Get-ChildItem`, `Get-Content`,
`Select-String`, `Get-ChildItem -Recurse`.

### 9. New project with Overleaf + GitHub: always use `setup_project.ps1`

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

`helpi.ps1` line 494 called `[Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory()` unconditionally.
That class only loads in interactive PowerShell hosts with the PSReadLine module. Non-interactive callers
(Gemini CLI via `! helpi ...`, `powershell.exe -NoProfile`, CI scripts) crash with a hard error at that line.

**Fix applied 2026-05-16:** wrapped in `try { ... } catch {}` -- history is saved when possible, silently
skipped otherwise. The fix is already in `helpi.ps1`; do not revert it.

**Symptom if reverted:** agent reports "cannot run helpi" or PS crashes immediately after the preview line.

---

## Adding new entries
When an issue recurs (2+ times), add it here and update the compact block in
`~/.claude/CLAUDE.md` and `~/.codex/config.toml`.
