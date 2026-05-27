# /close — End a working session and update the AI log

The user has finished working and wants to close the session cleanly.

## Project root detection

Walk up from the current working directory until you find a folder starting with `Pub_`, `Pro_`, or `PhD_`. That is the project root.

## What to do

0. **Read `_session_draft.md`** if it exists in the project root — this is the live file-touch log written incrementally during the session. Use it as the authoritative list of files touched. Delete the file after writing the session block in step 3.

1. **Get the git ref** from `code/` if it is a git repo — use the **PowerShell tool**:
   ```
   git -C "<root>/code" rev-parse --short HEAD 2>$null
   ```
   Or if running via Bash tool, use `2>/dev/null` (not `2>$null`). Use `—` if no git repo or the command fails.
2. **Ask the user** (in a single prompt, bullet-point style) for anything not already clear from the conversation or `_session_draft.md`:
   - One-sentence outcome
   - Next steps (can be "none")
   Skip asking if the answer is obvious from context.
3. **Append** to `_ai_log.md` — find the `## Session YYYY-MM-DD` block that was opened at the start and fill it in, or append a complete block if none exists:

```
## Session YYYY-MM-DD
**Agent:** Claude Sonnet 4.6
**Goal:** <from session start or conversation>
**Files touched:**
- `<file>` — <one-line description of change>
**Outcome:** <one sentence>
**Next steps:** <bullet points or "none">
**Git ref:** <short SHA or —>
```

3.2 **Update the platform map** — scan the session for platform/environment discoveries (tool failures, workarounds, new paths used, software not where expected). Cross-check against `AI_auto/known_issues.md`. Rules:
   - If nothing new: skip entirely, say nothing.
   - If 1–2 new patterns: append a full entry to `AI_auto/known_issues.md` (this is the single source of truth all agents read). Use `**Status:** open` if the root cause can be fixed in a file; `**Status:** platform-fact` otherwise. Include **Affects:** and **Fix:** fields for open entries. Also add the short version to the inline Platform facts block in `~/.claude/CLAUDE.md`. Tell the user in one line: "Platform map updated: [what was added]. Run /catch-up to apply the fix."
   - Only add things an agent could act on upfront — not transient failures or network blips.

3.5 **Clear the draft** — delete `_session_draft.md` from the project root if it exists:
   ```
   Remove-Item "<root>/_session_draft.md" -ErrorAction SilentlyContinue
   ```

3.6 **Compress the log** — immediately after appending the session block, run:
   ```
   helpi 22 <project>
   ```
   where `<project>` is the folder name found in the directory walk (e.g. `Pub_XXX` or `AI_auto`). The script trims sessions older than the most recent 4 to one-liners automatically and is safe to run every time — it exits silently if the log is still short. Report any output it produces.

3.7 **Write state card** — overwrite (never append) `_state/current.md` in the project root. Create `_state/` if it does not exist. **Always Read the file first** (even if you just created it) — the Write tool requires a prior Read or it will error:

```markdown
# State — YYYY-MM-DD
**Phase:** <current phase from .claude/CLAUDE.md, or "—" if not set>
**Last session:** <one-sentence outcome from step 3>
**Next:** <next steps from step 3, as bullet points>
**Git ref:** <short SHA or —>
**Agent:** Claude Sonnet 4.6
```

This file is always overwritten — it is the single "where are we now" source, not a history.

4. **Update `.claude/CLAUDE.md`** — read the current file and update any sections that changed this session:
   - `Current phase` — if the project was submitted, revision received, accepted, etc.
   - `Standing constraints` — if new notation was locked, a section frozen, or a reviewer mandate established
   - `What NOT to touch` — if any files were submitted or frozen this session
   - `Key files` — if a new primary manuscript version was created (e.g. `_R1B.tex` replacing `_R1.tex`)
   Only edit sections that actually changed. Tell the user what you updated (one line per change), or "CLAUDE.md unchanged" if nothing needed updating.

5. **Auto-regenerate the handover** — run:
   ```
   pwsh -NoProfile -File "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1" -Project <project>
   ```
   Do not ask the user — just run it. Confirm with "Handover regenerated." when done.

6. **Remind** the user of the one remaining optional step:
   - Push to Overleaf if manuscript files were changed: `helpi 2 <project>`
