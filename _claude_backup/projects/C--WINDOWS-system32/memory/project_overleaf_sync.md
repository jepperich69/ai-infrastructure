---
name: Overleaf auto-sync system
description: Automated system that pulls all Overleaf papers locally every 4 hours via Windows Task Scheduler
type: project
---

All scripts live in:
`C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\`

**Files:**
- `sync_all.ps1` — main script: checks papers.csv for new projects (clones if missing), then pulls updates for all registered projects
- `projects.json` — registry of all cloned repos (path + branch per project), ~60 entries
- `papers.csv` — source of truth: maps Overleaf git URLs to local Pub_ folders. Add a row here to register a new paper.
- `setup_project.ps1` — one-off helper to manually add a single project
- `fetch_overleaf.ps1` (Desktop) — fetches full project list from Overleaf using browser session cookie (overleaf_session2)

**Scheduled task:** "AI Auto Sync" runs every 4 hours via Windows Task Scheduler, calling sync_all.ps1.

**Adding a new paper:**
1. Create `Pub_XXX` folder under Publikationer
2. Add a row to papers.csv (OverleafName, GitUrl, LocalFolder, SubFolder=Overleaf_source)
3. Next auto-run clones it automatically

**Each paper clones into:** `Pub_XXX\Overleaf_source\` (full Overleaf folder structure preserved by git)

**Duplicate handling:** if two Overleaf projects map to the same folder, second one goes into `Overleaf_source_2`

**Why:** Rich wanted automatic local backups of all Overleaf papers synced to his OneDrive/local folder structure.
