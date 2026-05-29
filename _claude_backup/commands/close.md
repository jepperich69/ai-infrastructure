# /close — End a working session and update the AI log

The user has finished working and wants to close the session cleanly.

**This skill runs in two phases.** Phase 1 runs in the current (Sonnet) context to gather session information. Phase 2 spawns a Haiku subagent that does all mechanical file operations — it does not reprocess the conversation history, so it is fast and cheap.

---

## Phase 1 — Gather context (you, the invoking agent)

### 1a. Detect project root and name

Walk up from the current working directory until you find a folder whose name starts with `Pub_`, `Pro_`, `PhD_`, or is exactly `AI_auto`. That folder is the project root. Note:
- `PROJECT_NAME` — the folder name (e.g. `AI_auto`, `Pub_Lemons`)
- `PROJECT_ROOT` — the full absolute path

### 1b. Read session draft

Read `<PROJECT_ROOT>/_session_draft.md` if it exists. This is the authoritative list of files touched during the session. If it does not exist, derive the file list from the conversation.

### 1c. Ask the user if needed

From the conversation context and the session draft, determine:
- **Goal** — what was the session about?
- **Outcome** — one sentence: what was accomplished?
- **Next steps** — what remains open? (can be "none")

If any of these are not clear, ask the user in a single message (bullet-point style). Skip the question entirely if the answer is obvious from context.

### 1d. Compose and spawn the Haiku agent

Once you have all context, call the Agent tool with `model: "haiku"` and the self-contained prompt below. Fill in every placeholder before spawning — the Haiku agent has no access to this conversation.

```
You are closing a research session. Perform each step below in order without pausing for confirmation. All file paths below are pre-approved.

SESSION CONTEXT
- Project: <PROJECT_NAME>
- Project root: <PROJECT_ROOT>
- Date: <YYYY-MM-DD>
- Goal: <GOAL>
- Outcome: <OUTCOME>
- Next steps: <NEXT_STEPS as bullet points, or "none">
- Files touched:
<FILES_TOUCHED — one "- `path` -- description" line per file>

STEP A — Git ref
Run via PowerShell tool: git -C "<PROJECT_ROOT>/code" rev-parse --short HEAD 2>$null
Use "--" if the command fails or there is no code/ repo. Store as GIT_REF.

STEP B — Append to _ai_log.md
Append to <PROJECT_ROOT>/_ai_log.md:

## Session <DATE>
**Agent:** Claude Sonnet 4.6
**Goal:** <GOAL>
**Files touched:**
<FILES_TOUCHED>
**Outcome:** <OUTCOME>
**Next steps:** <NEXT_STEPS>
**Git ref:** <GIT_REF>

---

STEP C — Delete session draft
Run via PowerShell tool: Remove-Item "<PROJECT_ROOT>/_session_draft.md" -ErrorAction SilentlyContinue

STEP D — Compress the log
Run via PowerShell tool: helpi 22 <PROJECT_NAME>
Report any output it produces.

STEP E — Write state card
First Read <PROJECT_ROOT>/_state/current.md (create _state/ with New-Item if it does not exist).
Then Write (overwrite) <PROJECT_ROOT>/_state/current.md with:

# State -- <DATE>
**Phase:** <check <PROJECT_ROOT>/.claude/CLAUDE.md for current phase, or use "--">
**Last session:** <OUTCOME>
**Next:** <NEXT_STEPS>
**Git ref:** <GIT_REF>
**Agent:** Claude Sonnet 4.6

STEP F — Update project CLAUDE.md
Read <PROJECT_ROOT>/.claude/CLAUDE.md if it exists.
Update only sections that changed this session:
- Current phase (if project was submitted, revision received, accepted, etc.)
- Standing constraints (if new notation was locked or a section frozen)
- What NOT to touch (if files were frozen this session)
- Key files (if a new manuscript version was created)
Say "CLAUDE.md unchanged" if nothing needed updating, or list what you changed (one line per change).

STEP G — Regenerate handover
Run via PowerShell tool:
pwsh -NoProfile -File "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\generate_handover.ps1" -Project <PROJECT_NAME>
Say "Handover regenerated." when done.

STEP H — Report
Output a brief summary of what was logged and whether the handover regenerated cleanly.
If any manuscript files (Overleaf_source/) were in the files-touched list, remind the user: run "helpi 4 <PROJECT_NAME>" to push changes to Overleaf.
```

---

## Phase 2 result

When the Haiku agent finishes, relay its summary to the user. The session is closed.
