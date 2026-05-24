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
**Status:** platform-fact
**Affects:** Local LaTeX compilation from Codex/non-interactive PowerShell sessions.
**Fix:** MiKTeX is initialized and updated for the normal `rich` Windows user as of 2026-05-24. Codex's sandbox identity can still see MiKTeX as "fresh" because it cannot write the per-user MiKTeX setup under `AppData`. For reliable local compile verification from Codex, run `helpi 6 <Project> -Force` with escalated permissions so it executes under the initialized user context.

Symptom if run inside the sandbox identity: `latexmk -pdf ...` exits immediately with "It seems that this is a fresh TeX installation. Please finish the setup before proceeding." Symptom is avoided by escalated compile. Verified on 2026-05-24 with a fresh local PDF build of `AI_auto/Overleaf_source/slides_division_meeting.tex`.

---

### 13. Unicode en/em-dashes cause encoding artifacts in latexdiff output
**Status:** fixed (2026-05-22)

Literal Unicode dashes (U+2013 en-dash, U+2014 em-dash) in `.tex` source files
produce garbled output ("Çö", "Çô") in latexdiff PDFs. Latexdiff's internal
normalisation step re-encodes the file and corrupts multi-byte UTF-8 sequences.

**Fix (applied 2026-05-22 to `AI_auto/submit.ps1`):**
1. Added `'--encoding=utf8'` to `$latexdiffArgs`.
2. Added Unicode dash pre-processing immediately before the latexdiff call:
   ```powershell
   $origText    = $origText    -replace [char]0x2014,'---' -replace [char]0x2013,'--'
   $revisedText = $revisedText -replace [char]0x2014,'---' -replace [char]0x2013,'--'
   ```
Also replaced Unicode dashes in affected project `.tex` files with LaTeX equivalents
(`---` / `--`) as a permanent fix. Any new manuscripts should use `---`/`--` throughout.

---

### 14. `codex exec` fails outside a git repo without `--skip-git-repo-check`
**Status:** platform-fact
When `codex exec` is called from a directory that is not inside a trusted git repo, it exits immediately with "Not inside a trusted directory and --skip-git-repo-check was not specified." Always add `--skip-git-repo-check` to `codex exec` calls in pipeline scripts that run from non-project directories (e.g., `AI_auto\_pipelines\...`).

---

### 15. Large string passed as `-p` argument to `claude.exe` causes `StandardOutputEncoding` error
**Status:** platform-fact
When `Get-Content $file -Raw` produces a very large string (tested: ~294KB) and is passed inline as the `-p` argument to `& claude -p (...)`, PowerShell fails with "StandardOutputEncoding is only supported when standard output is redirected." This is a Windows process-creation limit. Fix: cap per-agent output before accumulating into the prompt (done in pipeline skill template -- 20k chars for agent 1, 10k for others), or pipe large prompts via stdin (`Get-Content $file | & claude`).

---

### 16. `< $null` stdin redirect is not valid inside a PowerShell switch block
**Status:** platform-fact
`& command arg < $null` works at statement level but inside a `switch` block PowerShell raises "The '<' operator is reserved for future use." Do not add stdin null-redirect inside switch cases. At statement level outside switch, `< $null` is valid and skips the 3-second stdin wait that `claude -p` otherwise incurs.

---

### 17. `helpi 6 -Force` still opened the graphical TeX picker
**Status:** fixed (2026-05-24)
**Affects:** `AI_auto/helpi.ps1`
**Fix:** When command 6 is run with `-Force` and no `-TexFile`, `helpi.ps1` now resolves the newest `.tex` file in `Overleaf_source` and passes it explicitly to `compile_latex.ps1`.

Symptom: `helpi 6 AI_auto -Force` bypassed the top-level confirmation prompt but then stalled in `Out-GridView` inside `compile_latex.ps1` whenever a project had multiple `.tex` files.

---

### 18. `compile_latex.ps1` treated stale PDFs as successful warning builds
**Status:** fixed (2026-05-24)
**Affects:** `AI_auto/compile_latex.ps1`
**Fix:** The script now records the compile start time and only treats a nonzero LaTeX exit as a warning build if the PDF was freshly regenerated. It also catches PDF-open failures so a sandboxed viewer launch does not mask compile status.

Symptom: when MiKTeX exited before compiling, the script found an old PDF in `out/`, printed a warning, and attempted to open the stale PDF as if compilation had succeeded.

---

### 19. Relative `.\helpi.ps1` can fail in agent tool calls
**Status:** platform-fact

Some agent tool executions do not resolve `.\helpi.ps1` from the apparent project root, even when the request says the current directory is `AI_auto` or a `workdir` was supplied. Use the absolute script path instead:

```powershell
& "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.ps1" 6 AI_auto -Force
```

Symptom: `The term '.\helpi.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.` This has recurred during Codex LaTeX verification. For local compile verification, combine the absolute path with escalated execution because MiKTeX is initialized for the normal `rich` user, not the sandbox identity.

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
