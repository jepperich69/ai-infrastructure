---
name: Session logging behaviour
description: Claude must maintain _ai_log.md at start and end of every project working session
type: feedback
---

Always create or update `_ai_log.md` in the project root at the **start** and **end** of every working session on a paper project.

Format:
```markdown
## Session YYYY-MM-DD
**Goal:** [what we set out to do]
**Files touched:**
- `code/file.py` — [description of change]
**Outcome:** [what was accomplished]
**Next steps:** [what remains]
**Git ref:** [short commit hash(es) for rollback, once committed]
```

**Why:** The user wants a handover document that can be passed to another agent and a rollback trail. The `_ai_log.md` is that document. The auto-commit hook handles git, but the log requires intelligence — so Claude must write it.

**How to apply:** At session start, add a new `## Session` block with the goal. At session end (or when wrapping up), fill in Files touched, Outcome, and Next steps. If `_ai_log.md` doesn't exist, create it using `init_project_git.ps1` or create the file manually.
