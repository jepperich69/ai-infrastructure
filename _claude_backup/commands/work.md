# /work — Load research project context

The user wants to start a working session on a research project.

## Argument parsing

The argument (`$ARGUMENTS`) may be:
- A full path: `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\Pub_AssesTiming_Raoul_TBA`
- A project name: `Pub_AssesTiming_Raoul_TBA`
- Empty (you are already inside the project folder)
- Any of the above with an optional `--full` flag (e.g. `/work Pub_XXX --full` or `/work --full`)

Resolution rules:
1. Strip `--full` from the argument before resolving the project path. Note whether it was present.
2. If a full path is given, use it directly as the project root.
3. If a project name (starts with `Pub_`, `Pro_`, or `PhD_`), the root is `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\<name>`.
4. If empty, walk up from the current working directory until you find a folder whose name starts with `Pub_`, `Pro_`, or `PhD_` — that is the project root.

## Step 1 — Load main project context

### Fast flow (default)

1. **Read `_state/current.md`** in the project root. This is the primary context source — ≤20 lines covering current phase, last session outcome, and next steps.
2. **Check git status** of `code/` (if it exists and is a git repo): run `git -C "<root>/code" log --oneline -5` and `git -C "<root>/code" status --short`.

If `_state/current.md` does not exist, fall through to the full flow automatically and note it to the user.

### Full flow (`--full` flag, or state card missing)

1. **Read `_ai_log.md`** in the project root. If it does not exist, note that the project has no session history yet.
2. **Read `_handover.html`** if it exists (extract plain text, ignore HTML tags). If absent, skip.
3. **Check git status** of `code/` (if it exists and is a git repo): run `git -C "<root>/code" log --oneline -5` and `git -C "<root>/code" status --short`.

## Step 1b — Check for collaborator handovers

If `Overleaf_source/` exists in the project root, scan for files matching `_handover_*.md` where `*` is not `JR`. For each one found, read it and note the collaborator's initials, the date in the first heading, and their next steps. Surface these in the step 3 summary — e.g.:

> **Collaborator handover found:** `_handover_MN.md` (2026-04-23)
> Goal: … Outcome: … Next steps: …

This is informational only — no action required. If no such files exist, skip silently.

## Step 2 — Check and auto-update feeder projects

If `_feeders.json` exists in the project root:

For each registered feeder:
1. Read the feeder's `_ai_log.md`.
2. Find the date of the most recent `## Session` entry.
3. Compare to `last_log_session` stored in `_feeders.json`.
4. **If no new sessions:** silently note "up to date" — nothing more needed.
5. **If new sessions exist:** automatically (no prompting) read only the new session blocks and append a delta to `_feeders/<name>_digest.md`:

```markdown
---
### Delta — sessions since <last_synced_date>
- Session <date>: <one-sentence summary of what changed>
```

   Then update `last_log_session` and `last_synced_date` in `_feeders.json`. This is always done silently and automatically — the user should never need to trigger it manually.

## Step 3 — Summarise and ask for goal

Report to the user in this order (concise, bullet points):
- Project name and root path
- Current phase and last session outcome (from state card, or from AI log if full flow)
- Open next-steps
- Any uncommitted changes in `code/`
- Feeder status: for each feeder, one line — "up to date" or "updated: <what changed>"
- If any feeder digest was updated, offer to briefly summarise the new findings
- If fast flow was used and state card existed, add one line: *(fast load — run `/work --full` for full history)*

Then ask: **"What is the goal for today's session?"**

Do NOT write anything to `_ai_log.md` yet. Wait for the user's answer, then write the session-start block:

```
## Session YYYY-MM-DD
**Agent:** Claude Sonnet 4.6
**Goal:** <user's answer>
```
