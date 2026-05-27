---
name: Research infrastructure — Overleaf sync and AI session logging
description: How the Overleaf pull/push automation and AI session logging work
type: project
---

All automation scripts live in `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\`.

**Overleaf pull (automated, every 4h):** `sync_all.ps1`
- Uses a runspace pool (20 threads) for parallel pulls
- Pre-checks remote SHA via `git ls-remote` before pulling — skips unchanged repos
- Registry of all repos: `projects.json`

**Push to Overleaf (manual, per project):** `push_to_overleaf.ps1 -Project <name>`
- Stages, commits, and pushes local edits back to Overleaf's git endpoint

**Project code git init (one-time per project):** `init_project_git.ps1 -Project <name>`
- Initialises git in `code/`, adds `.gitignore`, creates first commit
- Also creates `_ai_log.md` in the project root

**Handover document generation:** `generate_handover.ps1 -Project <name>`
- Outputs session log + git history for both code and Overleaf source
- Pipe to a file or paste into a new agent session

**Auto-commit hook:** `auto_commit_hook.ps1` (registered as Claude Code Stop hook)
- Fires after every Claude turn
- Walks up from CWD to find a git repo and auto-commits any staged changes
