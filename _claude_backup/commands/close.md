# /close — End a working session and update the AI log

The user has finished working and wants to close the session cleanly.

**Execute all steps directly in the current context.** Do NOT spawn a subagent — all file operations are pre-approved in `~/.claude/settings.json` for the main context only; subagents have an independent permission model and will prompt.

---

## Step 1 — Detect project root and name

Walk up from the current working directory until you find a folder whose name starts with `Pub_`, `Pro_`, `PhD_`, or is exactly `AI_auto`. That folder is the project root. Note:
- `PROJECT_NAME` — the folder name (e.g. `AI_auto`, `Pub_Lemons`)
- `PROJECT_ROOT` — the full absolute path

## Step 2 — Read session draft

Read `<PROJECT_ROOT>/_session_draft.md` if it exists. This is the authoritative list of files touched during the session. If it does not exist, derive the file list from the conversation.

## Step 3 — Ask the user if needed

From the conversation context and the session draft, determine:
- **Goal** — what was the session about?
- **Outcome** — one sentence: what was accomplished?
- **Next steps** — what remains open? (can be "none")

If any of these are not clear, ask the user in a single message (bullet-point style). Skip the question entirely if the answer is obvious from context.

## Step 4 — Execute close steps

Once you have all context, run each step below in order without pausing for confirmation.

### A — Git ref
Run via PowerShell tool: `git -C "<PROJECT_ROOT>/code" rev-parse --short HEAD 2>$null`
Use "--" if the command fails or there is no code/ repo. Store as GIT_REF.

### B — Append to _ai_log.md
Read `<PROJECT_ROOT>/_ai_log.md`, then use Edit to append:

```
## Session <DATE>
**Agent:** Claude Sonnet 4.6
**Goal:** <GOAL>
**Files touched:**
<FILES_TOUCHED — one "- `path` -- description" line per file>
**Outcome:** <OUTCOME>
**Next steps:** <NEXT_STEPS>
**Git ref:** <GIT_REF>

---
```

### C — Delete session draft
Run via PowerShell tool: `Remove-Item "<PROJECT_ROOT>/_session_draft.md" -ErrorAction SilentlyContinue`

### D — Compress the log
Run via PowerShell tool: `helpi 22 <PROJECT_NAME>`
Report any output it produces.

### E — Write state card
First Read `<PROJECT_ROOT>/_state/current.md` (create `_state/` with New-Item if it does not exist).
Then Write (overwrite) `<PROJECT_ROOT>/_state/current.md` with:

```
# State -- <DATE>
**Phase:** <check <PROJECT_ROOT>/.claude/CLAUDE.md for current phase, or use "--">
**Last session:** <OUTCOME>
**Next:** <NEXT_STEPS>
**Git ref:** <GIT_REF>
**Agent:** Claude Sonnet 4.6
```

### F — Update project CLAUDE.md
Read `<PROJECT_ROOT>/.claude/CLAUDE.md` if it exists.
Update only sections that changed this session:
- Current phase (if project was submitted, revision received, accepted, etc.)
- Standing constraints (if new notation was locked or a section frozen)
- What NOT to touch (if files were frozen this session)
- Key files (if a new manuscript version was created)
Say "CLAUDE.md unchanged" if nothing needed updating, or list what you changed (one line per change).

### G — Regenerate handover
Run via PowerShell tool:
`pwsh -NoProfile -File "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1" -Project <PROJECT_NAME>`
Say "Handover regenerated." when done.

### H — Report
Output a brief summary of what was logged and whether the handover regenerated cleanly.
If any manuscript files (Overleaf_source/) were in the files-touched list, remind the user: run `helpi 4 <PROJECT_NAME>` to push changes to Overleaf.
