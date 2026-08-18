# Environment map â€” this machine

Reference document. The compact version of this lives inline in `~/.claude/CLAUDE.md`
and `~/.codex/config.toml`. Update both when new facts are confirmed.

---

## Software inventory

| Tool | Version | Path | In PATH? |
|---|---|---|---|
| PowerShell | 7.6.1 | `C:\Program Files\PowerShell\7\pwsh.exe` | Yes |
| R | 4.5.2 | `C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe` | **No** |
| Python (miniconda) | 3.13.9 | `C:\Users\rich\AppData\Local\miniconda3\python.exe` | **No** |
| conda | â€” | `C:\Users\rich\AppData\Local\miniconda3\Scripts\conda.exe` | **No** |
| pdflatex / latexmk / xelatex | MiKTeX | `C:\Users\rich\AppData\Local\Programs\MiKTeX\miktex\bin\x64\` | Yes |
| git | 2.54.0 | `C:\Program Files\Git\cmd\git.exe` | Yes |
| gh (GitHub CLI) | 2.88.1 | `C:\Program Files\GitHub CLI\gh.exe` | Yes |
| Node.js | v24.15.0 | `C:\Program Files\nodejs\node.exe` | Yes |
| Stata | â€” | â€” | **Not installed** |
| Julia | â€” | â€” | **Not installed** |

Conda environments: `base` (default), `pyopt`

---

## Key paths

| Location | Path |
|---|---|
| JR root | `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\` |
| Research projects | `...\JR\Publikationer\` (101 folders, prefix `Pub_` / `Pro_` / `PhD_`) |
| AI infrastructure | `...\JR\AI_auto\` |
| Sensitive data | `...\JR\Sensitive_Data\` â€” agents must not read or write here |
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
- `platform-fact` â€” not fixable in code; agents must route around it permanently
- `fixed (YYYY-MM-DD)` â€” was broken, now patched; do not revert
- `open` â€” confirmed bug with a known fix not yet applied; `/catch-up` will handle it

---

### 1. `python3` not available
**Status:** platform-fact
`python3` is a Windows Store alias â†’ exit 49. Use full path:
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
Fragile â€” Base64 encoding from Bash corrupts silently. Write a `.ps1` file instead.

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
- `helpi 4` (push_to_overleaf.ps1) runs `git push origin`, so it pushes to GitHub â€” Overleaf never updates.
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

### 11. Edit/Write tools write UTF-8 BOM â€” breaks YAML frontmatter and shebangs
**Status:** platform-fact

The Claude Code Edit and Write tools write files with a UTF-8 BOM (`EF BB BF`) on Windows. Any format that requires the file to start at byte 0 with specific content will silently break:
- Codex rejects `SKILL.md` files where `---` is not the literal first bytes â€” shows "missing YAML frontmatter delimited by ---" even when frontmatter is present.
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
produce garbled output ("Ã‡Ã¶", "Ã‡Ã´") in latexdiff PDFs. Latexdiff's internal
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

### 20. `&&` is not a valid statement separator in PowerShell
**Status:** platform-fact

The `&&` operator is only available in PowerShell 7+. On this machine, some environments (or the default PowerShell version invoked by agents) may not support it. Use `;` for sequential execution or `if ($?) { ... }` for conditional execution.

**Wrong pattern (do not repeat):**
`git status && git add .`

**Correct pattern:**
`git status; git add .`
or
`git status; if ($?) { git add . }`

Symptom: `The token '&&' is not a valid statement separator in this version.` This has occurred during git operations and multi-tool pushes.

### 21. Forum role files contain `=== DIGEST ===` placeholders â€” blackboard never updated
**Status:** fixed (2026-05-24)
**Affects:** `AI_auto/prompts/forum_roles/critic_sys.md`, `advocate_sys.md`, `realist_sys.md`

Each role file ended with:
```
=== DIGEST === (max 200 words)
=== STATE UPDATE === (proposed edits to BLACKBOARD)
```
These lines are prepended to the participant prompt. `Get-Section` in `run_forum.ps1` uses a regex that finds the **first** occurrence of `=== DIGEST ===` in the combined text â€” which is always the placeholder line in the role file, not the agent's actual response. Result: `$digest` = `"(max 200 words)"` and `$stateUpdate` = `"(proposed edits to BLACKBOARD)"` on every turn. The moderator receives garbage and produces a state that fails `Test-ForumState`, so `"moderator state rejected; previous state preserved"` is logged every round and the blackboard stays at its initial state throughout the entire forum run.

**Fix (applied 2026-05-24):** Removed the `=== DIGEST ===` and `=== STATE UPDATE ===` trailing lines from all three role files. The output-format instruction already appears in the main participant prompt; the role files should only carry role identity and behavioral guidance.

Symptom: every line in `forum_run_log.md` reads `moderator state rejected; previous state preserved`, and `forum_state.md` remains at `Round: 0` with no settled decisions after multiple rounds.

---

When an issue recurs (2+ times), append a new numbered entry here with:

```
### N. <short title>
**Status:** fixed (2026-05-25)
**Affects:** `<file path(s)>`
**Fix:** <exact one-paragraph description of what to change>
<symptom and context>
```

Change status to `fixed (YYYY-MM-DD)` once the fix is applied (by `/catch-up` or manually).
For issues that cannot be fixed in code, use `platform-fact` and omit the **Affects** / **Fix** fields.

Also update the compact block in `~/.claude/CLAUDE.md` and `~/.codex/config.toml` for platform-facts.

### 22. Convergence Forum fails when using Gemini agent
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1` 
**Fix:** Remove the redundant --yolo flag from the gemini invocation in Invoke-Agent. The CLI now forbids using both --yolo and --approval-mode together. Use only --approval-mode yolo.

Symptom: Forum finishes in seconds with Status: failed. output_r1_*.md files contain 'Cannot use both --yolo (-y) and --approval-mode together.'


### 23. Convergence Forum stalls during agent turn
**Status:** fixed (2026-06-03)
**Affects:** `AI_auto/run_forum.ps1`
**Fix:** Add `--skip-trust` to the `gemini` invocation in `Invoke-Agent`. While the CLI tool might already have it, ensuring it is passed explicitly prevents potential trust-blocking prompts in non-interactive sessions. Additionally, investigate why `output_r1_critic.md` shows `read_file` failing on `Overleaf_source` files due to ignore patterns.

Symptom: Forum rounds take several minutes and then time out or fail. Output logs show node-pty errors (`AttachConsole failed`) and tool execution failures.

---

### 24. `claude --print` returns "Not logged in" when spawned from within a Claude Code session
**Status:** platform-fact

Running `claude --print --bare` as a subprocess while an interactive Claude Code session is already active causes the child process to return "Not logged in - Please run /login" and exit 1. The forum script (`run_forum.ps1`) catches this pattern and aborts with "Agent 'claude' is not authenticated."

Root cause: Claude Code's credential store cannot be accessed by a nested subprocess while the parent session holds it. The interactive session authenticates via browser OAuth; the subprocess sees the credentials as unavailable.

Workaround: Always run `helpi 25` (and any script that invokes `claude --print`) from a fresh PowerShell window where no Claude Code session is currently active. Close this Claude Code session first, then run the forum.

---

### 25. Convergence Forum authentication check false positive
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1`
**Fix:** Anchored the "Not logged in" regex to the start of the line and added a fallback check: if a valid agent response (Digest and State Update) is found, the authentication error string is ignored.

Symptom: Forum crashes with "Agent 'gemini' is not authenticated" even when gemini is logged in. This happens if an agent hits a rate limit (429) or other error that causes the CLI to dump the full request body (which contains the project context and `AGENTS.md`, which in turn contains the string "Not logged in" as part of Issue #24's description).

---

### 26. Codex CLI stdin prompt missing in Convergence Forum
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1`, `~/.claude/skills/pipeline/skill.md`; same pattern appeared in an older generated `_pipelines/.../run_pipeline.ps1`.
**Fix:** When piping prompts into Codex from PowerShell, bypass the npm PowerShell shim and pass `-` as the explicit prompt argument so the CLI reads stdin. In the `/pipeline` skill template, use `codex.cmd exec ... -` instead of `codex exec ... -`. In `run_forum.ps1`, launch Codex through `node.exe` and the installed `@openai/codex/bin/codex.js` entrypoint with `System.Diagnostics.ProcessStartInfo.Arguments`; this avoids the PowerShell shim, `cmd.exe` quoting issues with OneDrive paths, and the Windows PowerShell 5.1 incompatibility with `ProcessStartInfo.ArgumentList`. Also changed the final forum console footer to print `Forum failed` when the blackboard state is failed instead of always printing `Forum concluded`.

Symptom: `helpi 25` with SAD mode and Codex agent finishes in a few seconds. `forum_run_log.md` marks each role as `FAILED`, each `output_r1_*.md` contains "No prompt provided. Either specify one as an argument or pipe the prompt into stdin.", and `final.md` has `Status: failed`, but the console still prints "Forum concluded."

---

### 27. Convergence Forum Codex turn can hang without writing output
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1`
**Fix:** Wrap Codex forum turns in a direct .NET `System.Diagnostics.Process` call to `node.exe` plus the installed Codex JS entrypoint, feed the prompt through redirected stdin, and enforce a configurable timeout (`-AgentTimeoutSeconds`, default 900). Avoid `Start-Job`: repeated background PowerShell jobs can fail with `Failed to load ... coreclr.dll, HRESULT: 0x800705AF`. Avoid `cmd.exe /c codex.cmd`: nested quoting can fail with `The filename, directory name, or volume label syntax is incorrect.` On timeout, kill the process tree, set `$LASTEXITCODE = 124`, and return `ERR | codex timed out after Ns before returning output.` so the forum writes `output_r*_*.md`, increments the failure count, and can close with `Status: failed` instead of leaving a half-created folder.

Symptom: after fixing stdin with `codex exec ... -`, `helpi 25` in Codex SAD mode creates `forum_run_log.md`, `forum_state.md`, `convergence_log.md`, and `prompt_r1_critic.txt`, then stalls indefinitely. No `output_r1_critic.md` and no `final.md` are written because `run_forum.ps1` is blocked waiting for `codex exec` to return.

---

### 28. Convergence Forum marks Codex 401/API errors as complete
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1`
**Fix:** Expand forum agent failure detection to match uppercase `ERROR:`, `401 Unauthorized`, `403 Forbidden`, login prompts, websocket connection failures, and stream-disconnect messages. However, do not treat nonzero exit codes or generic error-looking noise as failure when the transcript contains valid `DIGEST` and `STATE UPDATE` sections; Codex can produce a valid answer while PowerShell job output contains shim/noise lines.

Symptom: a Codex-only SAD smoke test for `verify if 2+2=4` produced `output_r1_*.md` files containing repeated `401 Unauthorized` websocket errors, but `forum_run_log.md` marked all roles as `complete` and `final.md` ended as `Status: adjourned`.

---

### 29. Convergence Forum loses valid digests when moderator output is malformed
**Status:** fixed (2026-05-25)
**Affects:** `AI_auto/run_forum.ps1`
**Fix:** Save raw moderator transcripts as `moderator_output_r*_*.md`. If moderator output fails `Test-ForumState`, apply a deterministic fallback update from the already-parsed `DIGEST` and `STATE UPDATE` sections instead of preserving the previous blackboard unchanged. Also make `Test-ForumState` use literal `.Contains(...)` checks rather than PowerShell `-like`, because section names such as `## [CONVERGENCE LOG]` contain brackets, and brackets are wildcard character classes in `-like` patterns.

Symptom: Codex SAD roles complete successfully and produce valid `=== DIGEST ===` / `=== STATE UPDATE ===` sections. Moderator output may also be valid and contain all required sections, but every moderator update is logged as `moderator state rejected`; `final.md` remains at `Round: 0` or relies on fallback state rather than accepting the moderator's `Status: converged`.

---

### 30. `helpi` cannot update last-project state from Codex sandbox
**Status:** platform-fact

When `helpi` runs from a Codex sandboxed session, the requested operation may complete successfully but the wrapper can still emit `Access to the path ... AI_auto\_state\last_project.txt is denied` when it tries to remember the last active project. Treat this state-write failure as non-fatal if the requested helper action reports success. If the last-project shortcut is needed, run the same `helpi` command from a normal PowerShell window or with escalated permissions.

Symptom: `helpi 22 Pub_StopGeometry_TBA -Force` reported successful log compression, then failed at `Set-Content -Path $helpiStateFile -Value $proj -Encoding UTF8` for `AI_auto\_state\last_project.txt`.

---

### 31. Gemini CLI skill discovery requires SKILL.md (uppercase) and junctions
**Status:** platform-fact
**Affects:** \~/.agents/skills/*\
**Discovery:** 
1. The Gemini CLI binary only discovers skills if the definition file is named \SKILL.md\ (case-sensitive). If named \skill.md\, it is ignored.
2. Creating symbolic links for skills requires Administrator privileges on this machine. Directory Junctions (\New-Item -ItemType Junction\) can be created without escalation and work correctly for skill discovery.

**Rule for agents:** When creating or linking skills for Gemini CLI, always use \SKILL.md\ and prefer Junctions over Symbolic Links.

---

### 32. Custom skill front matter needs explicit name
**Status:** fixed (2026-06-03)
**Affects:** `~/.claude/skills/style-edit/SKILL.md`, `~/.claude/skills/style-apply/SKILL.md`, `~/.claude/skills/pipeline/SKILL.md`
**Fix:** Add an explicit `name:` field to the YAML front matter of each custom skill, matching the directory name. Keep `SKILL.md` uppercase, ensure the first bytes are literal `---` with no UTF-8 BOM, and verify through the junctioned `.agents` paths with `gemini skills list --all`.

Symptom: one agent could infer the skill name from the directory while another reported `/style-edit` or related custom skills as not recognised after the `skill.md` to `SKILL.md` rename.

---

### 33. Infrastructure scripts moved into `AI_auto\scripts`
**Status:** platform-fact

The old absolute paths `AI_auto\helpi.ps1` and `AI_auto\generate_handover.ps1` no longer exist. Use either the `helpi` command on PATH or:

```powershell
& "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\scripts\helpi.ps1" <arguments>
```

For handover generation, use:

```powershell
& "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\scripts\generate_handover.ps1" -Project <project>
```

Symptom: PowerShell reports that the old root-level script paths are not recognized even though the scripts exist under `AI_auto\scripts`.

---

### 34. `---` in blackboard state causes `error: unknown option '---'` in claude CLI
**Status:** fixed (2026-06-08)
**Affects:** `AI_auto/scripts/run_forum.ps1`
**Fix:** In `Invoke-Agent` and the AutoClose block, stop passing `$promptText` as a CLI argument (`-p $promptText`). Instead pipe it via stdin (`$promptText | & claude ... -p`), matching the existing Gemini pattern. This prevents the Claude CLI argument parser from ever seeing `---` as a flag-like token.

Symptom: Forum succeeds in Round 1, then all Round 2 agent turns fail immediately with `error: unknown option '---'`. The blackboard state after Round 1 contains `---` (markdown horizontal rules) injected by agent output; when that state is embedded in the Round 2 prompt string and passed as a CLI argument, the claude binary's argument parser interprets the `---` as an unknown option flag.

---

### 35. Overleaf remote default branch can disagree with its accepted push branch
**Status:** fixed (2026-07-02)
**Affects:** `AI_auto/scripts/push_to_overleaf.ps1`
**Fix:** Resolve the accepted Overleaf branch from the project configuration or existing tracked branch before pull/rebase/push. Do not rely on `origin/HEAD`. If `origin/HEAD` points to `master` but the server rejects pushes with `wrong branch` and requests `main`, switch the local upstream to `origin/main` and avoid replaying parallel `master` and `main` histories.

Symptom: `helpi 4` reports the repository branch as `master`, rebases local commits onto `origin/master`, and repeatedly conflicts on `main.tex`. A direct push to `master` is then rejected by Overleaf with `wrong branch` and `Please use the main branch`, while `origin/main` contains a separate project history.

---

### 36. Gemini CLI: "Sign in with Google" OAuth dead; default model needs zero-quota gemini-2.5-pro avoided
**Status:** fixed (2026-06-19)
**Affects:** `~/.gemini/settings.json`, `AI_auto/scripts/run_forum.ps1` (Invoke-Agent "gemini" case and AutoClose block)
**Fix:** Two independent issues, both on this machine:
1. Google killed the "Sign in with Google" OAuth login for Gemini CLI individuals, redirecting to the separate "Antigravity" product (`agy.exe`, a different CLI with a different flag set — not a drop-in replacement). Switched `~/.gemini/settings.json` `security.auth.selectedType` from `"oauth-personal"` to `"gemini-api-key"` to use the existing `GEMINI_API_KEY` env var instead.
2. That API key's free tier has `limit: 0` quota for `gemini-2.5-pro` (the CLI's default model) but works fine on `gemini-2.5-flash`. Set `GEMINI_MODEL=gemini-2.5-flash` persistently (User env var) as the interactive default, and added `--model gemini-2.5-flash` explicitly to both `gemini` invocations in `run_forum.ps1` so the Forum doesn't silently depend on that env var.

Symptom: Interactive `gemini` showed "Failed to sign in... This client is no longer supported for Gemini Code Assist for individuals... migrate to Antigravity" and hung after completing browser auth. Non-interactive calls (`gemini --approval-mode plan ...` as used by `run_forum.ps1`) failed with repeated `503 UNAVAILABLE` retries; the real cause (confirmed via direct REST call to `generateContent`) was `429 RESOURCE_EXHAUSTED` / `limit: 0` for `gemini-2.5-pro` on the free-tier key, which the CLI's retry wrapper reported as a generic 503.

**Note:** `agy.exe` ("Antigravity CLI", installed separately, `C:\Users\rich\AppData\Local\agy\bin\agy.exe`) is unrelated to this fix — it's a different product with a Claude-Code-like flag set (`-p`, `--dangerously-skip-permissions`, `--add-dir`, `--continue`), not wired into AI_auto. The old `gemini` (`@google/gemini-cli` npm package) remains the agent used by Convergence Forum.

**Update (2026-06-22):** Interactive `gemini` (CLI v0.47) was defaulting/being switched to `gemini-3.5-flash`, whose free-tier daily quota is tiny — exhausting it produces `Usage limit reached for gemini-3.5-flash` surfaced as the generic `[API Error: An unknown error occurred.]`. Direct REST test of the free-tier `GEMINI_API_KEY`: `gemini-2.5-flash` -> 200 OK; `gemini-3.5-flash` -> 200 on a single ping but quota-capped; `gemini-3-flash` -> 404 (not a real id). Pinned `model.name = gemini-2.5-flash` in `~/.gemini/settings.json` as belt-and-suspenders (note CLI bug #5373/#2205: settings.json `model` can be ignored on Windows, so `GEMINI_MODEL` env var remains the primary lever; both are now set). The Forum is unaffected because `run_forum.ps1` hard-pins `--model gemini-2.5-flash`; a Forum "out of tokens" failure is the shared free-tier daily request cap, not a model-selection bug — wait for the 24h reset or enable billing. Google's individual "Sign in with Google" OAuth for the classic `gemini` CLI is gone (redirects to Antigravity, retired for unpaid/Google One users 2026-06-18); a consumer **Gemini/Google AI Pro subscription does NOT grant API quota** to the API-key path — higher 3.x quota requires either a paid (billing-enabled) AI Studio key or using Antigravity CLI interactively (but `agy.exe` hangs non-interactively, see issue #37, so it cannot drive the Forum).

---

### 37. Antigravity CLI (`agy.exe`) hangs indefinitely in any non-interactive invocation
**Status:** open
**Affects:** `C:\Users\rich\AppData\Local\agy\bin\agy.exe`; would affect `AI_auto/scripts/run_forum.ps1` if wired in as a Forum agent
**Symptom:** `agy --dangerously-skip-permissions -p "<prompt>"` (and `agy models`) returns instantly with correct output when typed directly into a real interactive terminal by the user. The identical command hangs forever with zero stdout/stderr when launched from any automated/non-console context: PowerShell background job, `Start-Process` with `-RedirectStandardOutput`/pipe-based redirection, and `cmd.exe`-native `> file 2>&1` redirection were all tried and all hang identically. No error is ever printed; the process must be killed manually (`Stop-Process`).
**Likely cause:** `agy` probably needs a genuinely attached console/pty handle (similar root cause to issue #23's `gemini-cli` node-pty/`AttachConsole` failures), not just stdin/stdout pipes, likely for its own internal tool-execution sandboxing.
**Other blocker found in passing:** `-p`/`--print` only accepts the prompt as a literal CLI argument — no stdin fallback (`flag needs an argument: -p` when stdin is empty). This would reopen the `---`-in-argument parser bug fixed for `claude` in issue #34, independent of the hang.
**Status quo:** Do not wire `agy` into `run_forum.ps1` until the console-attachment issue is understood (e.g. via `wt.exe`/ConPTY-aware launching) — it is currently unusable headless. The Convergence Forum continues to use `gemini` (see issue #36) and `claude`/`codex` only.

**Update (2026-06-22): OAuth login regression in agy v1.0.9/1.0.10 + the two-track model convention.**
Interactive `agy` login failed at the final token exchange with `token exchange failed: Post "https://oauth2.googleapis.com/token": read tcp ... connection reset by peer`, every attempt, browser step succeeding first. This is NOT a network/firewall/account problem (the OAuth endpoint was confirmed reachable: a direct `Invoke-WebRequest` POST returned a clean HTTP 400, and the free-tier API key independently worked). It is a **known regression in agy v1.0.9 and v1.0.10** (both released ~2026-06-19) — same error reported by users on other OSes on the Google AI Developers forum (`discuss.ai.google.dev/t/oauth2-errors-this-morning/171616`); Google staff acknowledged, no hotfix.
**Fix applied:** downgraded to the known-good **v1.0.8**. The release asset is named `antigravity.exe` inside `agy_cli_windows_x64.zip` from `https://github.com/google-antigravity/antigravity-cli/releases/download/1.0.8/agy_cli_windows_x64.zip`; copy it over `C:\Users\rich\AppData\Local\agy\bin\agy.exe`. After downgrade, login succeeds and the token caches (subsequent launches sign in silently as `jeppe.rich@gmail.com (Google AI Pro)`, Gemini 3.5 Flash). A backup of the broken binary is at `agy.exe.bak_20260622_085759`.
**Do NOT update agy** (`irm https://antigravity.google/cli/install.ps1 | iex`) or let it self-update until Google fixes the regression — there is no documented version-pin flag, so updating re-installs the broken 1.0.10. If it breaks again, re-do the 1.0.8 swap.

**Update (2026-06-22, later): it auto-updated itself back to 1.0.10 within hours** (next interactive launch reverted `agy.exe` to 153,648,792 bytes / v1.0.10, eligibility check failing again with the same `wsarecv: connection forcibly closed`). The do-not-update warning is insufficient because agy self-updates silently on launch. **New pin mechanism applied: after swapping 1.0.8 in, set the binary read-only** so the self-updater cannot overwrite it:
```powershell
Stop-Process -Name agy -Force -ErrorAction SilentlyContinue   # unlock the file
Set-ItemProperty "$env:LOCALAPPDATA\agy\bin\agy.exe" IsReadOnly $false
Copy-Item <path-to-1.0.8 antigravity.exe> "$env:LOCALAPPDATA\agy\bin\agy.exe" -Force
Set-ItemProperty "$env:LOCALAPPDATA\agy\bin\agy.exe" IsReadOnly $true
```
Version fingerprints: **v1.0.8 = 151,180,952 bytes; v1.0.10 = 153,648,792 bytes** (quick check: `(Get-Item "$env:LOCALAPPDATA\agy\bin\agy.exe").Length`). The clean 1.0.8 binary is also kept locally as `agy.exe.1782111695774488500.old` and re-downloadable from the GitHub 1.0.8 release (URL above).

**Update (2026-06-22, even later): read-only was NOT enough — the updater clears the read-only attribute then delete-and-replaces the file, reverting to 1.0.10 on the next launch.** There is no config file, env var, or CLI flag to disable auto-update (the install is literally just `%LOCALAPPDATA%\agy\bin\agy.exe`, nothing else). **The working pin is an ACL deny** for the current user (the identity the updater runs as) on both the file and its parent `bin` folder, blocking the three update vectors (in-place overwrite, delete, create-new). Verified all three raise `UnauthorizedAccessException` afterwards while the binary stays 1.0.8:
```powershell
$bin = "$env:LOCALAPPDATA\agy\bin\agy.exe"; $dir = "$env:LOCALAPPDATA\agy\bin"
Stop-Process -Name agy -Force -ErrorAction SilentlyContinue; Start-Sleep -Milliseconds 800
Set-ItemProperty $bin IsReadOnly $false -ErrorAction SilentlyContinue
Copy-Item <path-to-1.0.8 antigravity.exe> $bin -Force
$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$a = Get-Acl $bin; $a.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($me,"Write,Delete","None","None","Deny"))); Set-Acl $bin $a
$d = Get-Acl $dir; $d.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($me,"CreateFiles,DeleteSubdirectoriesAndFiles,Delete","None","None","Deny"))); Set-Acl $dir $d
```
The deny ACEs leave ownership + WriteDAC intact, so to **unlock for a legitimate future upgrade** (once Google fixes the 1.0.9+ regression), remove the deny rules then swap:
```powershell
$bin = "$env:LOCALAPPDATA\agy\bin\agy.exe"; $dir = "$env:LOCALAPPDATA\agy\bin"
foreach ($p in $bin,$dir) { $x = Get-Acl $p; $x.Access | ? AccessControlType -eq Deny | % { $x.RemoveAccessRule($_) | Out-Null }; Set-Acl $p $x }
```
If a launch ever shows 1.0.10 again, the deny ACEs were removed/reset — re-apply the lock block above.

**Update (2026-06-22, final): there IS a proper updater kill-switch — the env var `AGY_CLI_DISABLE_AUTO_UPDATE`** (found by stringing the binary; the earlier "no env var" claim was wrong). Set it user-scoped: `[Environment]::SetEnvironmentVariable('AGY_CLI_DISABLE_AUTO_UPDATE','1','User')`. With this set, agy never checks/stages/applies an update, so the ACL lock above is now just a backstop (keep both — env var prevents the attempt, ACL blocks the apply if the var is ever missing). Other useful agy env vars seen in the binary: `AGY_CLI_DISABLE_NEW_USAGE`, `AGY_CLI_HIDE_ACCOUNT_INFO`, `AGY_CLI_LOGO_STYLE`. Note: agy stages downloaded updates under `%LOCALAPPDATA%\antigravity\staging` and records `~/.gemini/antigravity-cli/updater/update_status.json` ("Update successful, restart CLI to use") — that staged copy is what the ACL lock prevents from overwriting `bin\agy.exe`.

**agy context wiring (AGENTS.md): agy shares the classic gemini `~/.gemini` dir** (its data lives under `~/.gemini/antigravity-cli/`; OAuth creds, builtin skills, conversations, and its own `settings.json` `{enableTelemetry, trustedWorkspaces}` are there). agy **auto-discovers `AGENTS.md`/`GEMINI.md`** with no `contextFileName` setting required, and **traverses parent dirs from the cwd** (so a project's helpi-generated `AGENTS.md` plus any ancestor is read automatically — workspace context already works). For *global* context the global `AGENTS.md` exists in both candidate roots: `~/.gemini/AGENTS.md` (classic gemini global) and `~/.gemini/antigravity-cli/AGENTS.md` (agy data root), since it was unclear which agy treats as its Global Customizations Root. The two are a **hard link** (same file data, so they never drift) — symlink was preferred but needs admin/Developer Mode, which is off. Caveat: a hard link can break if an editor saves the canonical file via write-temp-then-rename (atomic save) rather than in place; if `fsutil hardlink list "$env:USERPROFILE\.gemini\antigravity-cli\AGENTS.md"` ever shows only one path, re-link with `Remove-Item <link> -Force; cmd /c mklink /H <link> <target>` (or make it a real symlink from an elevated shell). Cannot be verified headlessly (agy `--print` hangs, this issue); verify interactively by running `agy` in a project dir and asking it to list the absolute paths of the customization/context files it loaded (its system prompt supports exactly that request).
**Two-track model convention (now enforced):**
- *Interactive / manual* Gemini use -> `agy` (Antigravity, Google AI Pro subscription, free 3.5 Flash). Not usable in automation (this issue's hang).
- *Automation* (Convergence Forum `run_forum.ps1`, `/pipeline` skill) -> classic `gemini` (`@google/gemini-cli`) hard-pinned to `--model gemini-2.5-flash` on the free-tier `GEMINI_API_KEY`. Both `run_forum.ps1` calls already pin it; `/pipeline` SKILL.md's gemini round was missing the flag and was fixed on 2026-06-22 (it could otherwise drift onto 3.x and exhaust the tiny free quota mid-run). See issue #36 for the API-key/quota background.

---

### 38. `helpi 4` (and other network git ops) hang in headless agents when the remote is ahead
**Status:** fixed (2026-06-25)
**Affects:** `AI_auto/scripts/config.ps1` (the fix); symptom seen in `push_to_overleaf.ps1` (helpi 4), also latent in `sync_one.ps1`/`sync_all.ps1` (helpi 2/3)
**Fix:** Force non-interactive git for all infra scripts. `config.ps1` is dot-sourced by every script, so set there:
```powershell
$env:GIT_TERMINAL_PROMPT = "0"      # never prompt for username/password
$env:GCM_INTERACTIVE     = "Never"  # Git Credential Manager: no GUI/prompt
$env:GIT_PAGER           = "cat"    # never invoke a blocking pager
```
This converts a silent infinite hang into a fast, actionable error (e.g. push fails with a clear message) so the script exits instead of blocking forever.

**Symptom:** Running `helpi 4` from a headless agent (agy / Codex sandbox / scheduled task — anything with no attached TTY) hung indefinitely with no output when the Overleaf remote was ahead of local. When the remote was *not* ahead the push usually went straight through on cached credentials, so the hang looked branch-state-specific; in reality the extra `fetch -> rebase -> push` round-trip taken on the "remote ahead" path is more likely to require a credential refresh, and any git credential / Git Credential Manager prompt blocks forever on a stdin that never arrives in a headless context.

**Note:** With the guard in place, a genuinely missing/expired credential now makes `fetch`/`push` *fail fast* rather than hang — the correct behavior for automation. On this machine credentials are normally served non-interactively by Windows Credential Manager once stored, so interactive sessions are unaffected. Distinct from issue #35 (Overleaf branch disagreement), which is about *which* branch is pushed, not about hanging.

### 39. Persist retrieved literature: seed `Literature/_retrieved_sources.md` in scaffolds + document
**Status:** fixed (2026-07-02)
**Affects:** `AI_auto/scripts/setup_project.ps1` (helpi 1 paper scaffold), the generic scaffold (helpi 27), the per-project `.claude/CLAUDE.md` template(s), and `infrastructure.html`.
**Context:** A global rule now lives in `~/.claude/CLAUDE.md` ("Persisting retrieved literature"): whenever a fetched web source (paper, book, standard, dataset doc) backs a claim that lands in the work, the agent saves the source file into the project `Literature/` folder and logs it in `Literature/_retrieved_sources.md` (citation, bib key, URL, retrieval date, where used, verified facts/section anchors). First applied 2026-06-27 in `Pub_SAA_PMIP_MC` (Shapiro et al. 2009 -> entropic risk measure anchor). The rule works from memory today; this entry makes it self-supporting in the scaffolds.
**Fix (to apply in an AI_auto session via `/catch-up`):**
1. `helpi 1` paper scaffold: create `Literature/_retrieved_sources.md` with the standard header + one commented format template (citation / bib key / source URL / retrieved date / used in / verified facts).
2. `helpi 27` generic scaffold: currently skips `Literature/`. Create an empty `Literature/` plus the same `_retrieved_sources.md` stub, so paper and generic projects stay symmetric.
3. Per-project `.claude/CLAUDE.md` template(s): add a one-line pointer — "Retrieved web sources are saved to `Literature/` and logged in `Literature/_retrieved_sources.md`."
4. `infrastructure.html`: document the retrieved-sources convention alongside the `Literature/` folder description, and regenerate docs with `helpi 16`.
**Reference stub** (the working version created by hand in `Pub_SAA_PMIP_MC/Literature/_retrieved_sources.md`) can be copied as the template.

---

### 40. Codex sandbox cannot execute miniconda Python under AppData
**Status:** platform-fact
**Affects:** Codex/math-verification sessions that call `C:\Users\rich\AppData\Local\miniconda3\python.exe` from a project sandbox.

The managed Codex workspace sandbox can read/write inside the active project but may not execute the miniconda interpreter under `AppData`. Symptom: the exact full-path preflight
```powershell
& "C:\Users\rich\AppData\Local\miniconda3\python.exe" -c "import sympy; print(sympy.__version__)"
```
fails inside the sandbox with "The term ... python.exe is not recognized" even though the interpreter exists and works outside the sandbox. For math-verification tasks, do not spend a failed first attempt proving this again. Run the required SymPy preflight with `sandbox_permissions: "require_escalated"` immediately, using prefix rule `["C:\\Users\\rich\\AppData\\Local\\miniconda3\\python.exe"]`. Once approved, execute generated verification scripts the same way, preferably with absolute script paths because escalated process resolution may not honor the tool workdir.

---

### 41. `generate_docs.ps1` (helpi 16) produced stale PDFs when Edge was already open
**Status:** fixed (2026-06-30)
**Affects:** `helpi 16` / `scripts\generate_docs.ps1` PDF output (`infrastructure_full.pdf`, `infrastructure_summary.pdf`).

When a normal Microsoft Edge window was already running, the script's headless `msedge --print-to-pdf` call was intercepted by the running instance and served a **stale cached render**: the `.pdf` got a fresh modification timestamp but old content. The result looked regenerated and silently was not, so a doc update could be committed with a PDF that omitted the new content (caught this session when the `/verify-math --model` section was missing from the committed PDF despite a successful-looking regen).

**Fix applied:** `Make-Pdf` now launches Edge with a throwaway `--user-data-dir` (a temp profile under `$env:TEMP`, removed afterward) so it spawns an independent instance that cannot share the running browser's cache and does not disturb the user's open windows. It also deletes any prior PDF before rendering (so a failed render can never masquerade as fresh) and polls up to 30s for the output instead of a fixed 4s sleep (the isolated profile's first run is slower). Validated by regenerating with Edge open: the new content is present in the output PDF.

---

### 42. PowerShell decodes external command stdout using legacy console encoding, corrupting UTF-8
**Status:** fixed (2026-06-30)
**Affects:** `AI_auto/scripts/submit.ps1`
**Fix:** Set `[Console]::OutputEncoding = [System.Text.Encoding]::UTF8` in scripts that capture the text output of external tools (like `latexdiff` run via Strawberry Perl). This forces PowerShell to decode the external process's stdout bytes as UTF-8 rather than using the legacy console code page (such as Danish CP850), avoiding encoding artifacts like `Ç¿` for curly quotes and `é¼` for the Euro symbol `€`.


---

### 43. `research-close` skill references stale handover script path
**Status:** fixed (2026-08-18)
**Affects:** `C:\Users\rich\.agents\skills\research-close\SKILL.md`
**Symptom:** The close workflow says to run `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1`, but that path does not exist. The actual script is `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\scripts\generate_handover.ps1`.
**Fix:** Update `research-close/SKILL.md` to use the `scripts\generate_handover.ps1` path, or route handover regeneration through the supported `helpi 7 <project>` workflow.

### 44. Root `AI_auto\helpi.ps1` path is stale; use `scripts\helpi.ps1` or `helpi.cmd`
**Status:** platform-fact

Some generated instructions and compact platform notes still point agents to:
`C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.ps1`

That file does not exist on this machine. The actual entrypoints are:
- `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\scripts\helpi.ps1`
- `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.cmd`

Symptom: running the documented root `.ps1` path fails with "The term ...\AI_auto\helpi.ps1 is not recognized". Use the script under `scripts\` or the command shim instead. This is distinct from issue #43, which concerns the stale `generate_handover.ps1` path in the close skill.

---

### 45. PyTorch CPU wheel conflicts with the conda `pyopt` Intel OpenMP runtime
**Status:** platform-fact
**Affects:** Python experiments that import both the conda numerical stack and a pip-installed PyTorch CPU wheel in `pyopt`.

Installing/importing PyTorch in the existing `pyopt` conda environment can abort with a duplicate `libiomp5md.dll` initialization error. Do not suppress it with `KMP_DUPLICATE_LIB_OK=TRUE`; that can hide an unsafe mixed-runtime process. Use a project-local virtual environment based on the base Python interpreter and install the complete numerical stack there. Confirmed workaround in `Pub_PopInt_Part2_TBA\.venv_vae` with Python 3.13, PyTorch 2.13 CPU, NumPy 2.5.1, pandas 3.0.3, and scikit-learn 1.9.

Reproducibility note: optional library availability must not select a different algorithmic implementation. In this project, installing scikit-learn changed the former optional `k`-means branch and therefore the cluster labels. `code/maxent_cluster_sweep.py` now always uses the deterministic NumPy implementation that produced the original results.

---

### 46. `helpi 1` does not forward the optional Overleaf Git URL
**Status:** fixed (2026-08-18)
**Affects:** `AI_auto/scripts/helpi.ps1`
**Symptom:** `helpi 1 Pub_Seed_TBA https://git.overleaf.com/<id>` displays and invokes only `new_project.ps1 -Project Pub_Seed_TBA`. The URL is dropped, so the scaffold creates a placeholder `Overleaf_source/` instead of cloning and registering the supplied repository.
**Fix:** In the command-1 dispatch, pass the third positional value through as `-GitUrl` when present. Add a regression check covering both `helpi 1 <project>` and `helpi 1 <project> <git-url>`.

### 47. `auto_handover.ps1` has a UTF-8 BOM that breaks PowerShell execution
**Status:** fixed (2026-08-18)
**Affects:** `AI_auto/scripts/auto_handover.ps1`
**Symptom:** During `helpi 1`, PowerShell reads the leading BOM as part of the first token (`﻿#`) and then treats the later `param` block as a command. Project creation continues, but scheduled-task registration is not reliable.
**Fix:** Rewrite `auto_handover.ps1` as UTF-8 without BOM and verify that the `param` block is the first executable construct. Add a BOM check for `.ps1` infrastructure files.

### 48. Same-day sessions were tie-broken alphabetically, so the handover described the wrong session
**Status:** FIXED 2026-07-30
**Affects:** `AI_auto/scripts/ai_log_tools.ps1`, `Get-AiLogLatestSession`
**Symptom:** On any day with more than one session in `_ai_log.md`, the generated handover silently described whichever session's TITLE sorted highest alphabetically, not the newest one. The sort keyed on date descending, then on the title text after the date descending, and only then on `order` (position in the file) -- but the title tiebreak fires first and always decides, because same-day titles differ. In `Pub_PMIP_VSP` on 2026-07-30 there were six blocks; the handover reported block 2, "(the joint dwell, and the automation premium as a breakeven)", while the newest was block 5, "(ladder rung E2, ...)" -- "the j" sorts above "the a" and "(l". The failure is silent: the handover looks well-formed and internally consistent, and its "Next steps" section confidently describes work already finished. Any project doing several sessions a day has been handing over a stale brief.
**Fix:** APPLIED. The title tiebreak is removed; within one date, position in the file decides. Verified on `Pub_PMIP_VSP` (now returns the E2 block) and cross-checked against five other projects, which resolve unchanged.
**Related:** the same generator warns `Latest session block is incomplete: Outcome` when a block writes `**Outcome.**` with a period instead of `**Outcome:**` with a colon. The field is then emitted EMPTY rather than the block being rejected, so the handover looks fine apart from one blank line. Several `Pub_PMIP_VSP` blocks used the period form. Worth a tolerant match on `**Outcome**` followed by either punctuation.

---

### 49. Infrastructure launcher is `helpi.cmd`, not `helpi.ps1`
**Status:** platform-fact
**Affects:** Agent commands that invoke `helpi` by absolute path.

The file `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.ps1` no longer exists. The launcher is `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.cmd`, while the PowerShell implementation lives under `AI_auto\scripts\helpi.ps1`. Use the absolute `.cmd` launcher for documented `helpi N ...` operations. This supersedes the absolute-path example in issue 19.
