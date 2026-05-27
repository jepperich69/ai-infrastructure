---
name: AI_auto infrastructure project
description: The AI_auto folder is a project in its own right — the infrastructure built to support all research projects
type: project
---

The folder `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\` is both the home of the automation scripts AND a project being actively developed and extended.

**What it contains:**
- PowerShell scripts invoked via `helpi` (File Infrastructure layer): `sync_all.ps1`, `push_to_overleaf.ps1`, `compile_latex.ps1`, `generate_handover.ps1`, `init_project_git.ps1`, `rollback.ps1`, `status.ps1`, `snapshot.ps1`, `new_project.ps1`, `setup_project.ps1`, `link_projects.ps1`, `auto_commit_hook.ps1`
- `helpi.cmd` / `helpi.ps1` — the unified CLI dispatcher
- `infrastructure.html` — the canonical reference guide (last updated 2026-04-04); read this to get full context on any session about this project
- `projects.json` — registry of all Overleaf-linked projects
- `papers.csv`, `overleaf_projects.csv` — project metadata

**Two-layer architecture:**
- *File Infrastructure* — PowerShell scripts handle Overleaf sync, git, LaTeX compilation, folder scaffolding
- *AI Infrastructure* — Claude Code slash commands (`/work`, `/snapshot`, `/close`, `/family`, `/add-memory`) handle session logging, context loading, and feeder digests

**How to apply:** When the user opens a session on AI_auto, read `infrastructure.html` for full context. There is no `_ai_log.md` here yet (only a `logs/` folder for script output). Treat this like a research project session — confirm the goal before starting, log at the end.
