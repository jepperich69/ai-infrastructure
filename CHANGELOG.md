# Changelog — AI Research Infrastructure

All notable changes to this infrastructure are documented here.
A "change" is anything that affects how you or Claude interacts with the system.

---

## [v0.1] — 2026-04-05 — Initial stable release

### What this infrastructure does

**File layer (PowerShell / helpi)**
- Automatic Overleaf pull sync every 4 hours via Task Scheduler (`sync_all.ps1`)
- Push local edits back to Overleaf with pre-push rebase (`push_to_overleaf.ps1`)
- LaTeX compilation to PDF (`compile_latex.ps1`)
- Handover document generation (`generate_handover.ps1`)
- Project scaffolding (`new_project.ps1`, `setup_project.ps1`)
- Git rollback and status inspection (`rollback.ps1`, `status.ps1`)
- Git snapshot tagging for manuscript versions (`snapshot.ps1`)
- Overleaf project registry in `projects.json` / `papers.csv`
- `helpi` command dispatcher (numbered shortcuts for all scripts)

**AI layer (Claude Code / GPT slash commands)**
- `/work` — loads project context, reads `_ai_log.md`, confirms session goal
- `/close` — writes session block to `_ai_log.md`
- `/snapshot` — git-tags current manuscript state
- `/family` — ingests feeder project digest for cross-project knowledge
- `/add-memory` — adds a feeder file to Claude's project memory
- `/submit` — submission package generator
- `/respond` — reviewer response loop
- Auto-commit hook — commits every Claude response as a separate git commit

**Documentation**
- `infrastructure.html` — full reference guide with diagrams, command tables, worked examples, and printable one-pager

---

## [Unreleased] — develop

_Ongoing changes toward v0.2 go here. Move to a new `[vX.Y]` block when promoted._

- (nothing yet)

---

## When does a change deserve a new version?

- A new `helpi` command is added or removed
- An existing command's behavior changes in a way that would break current usage
- A new slash command is added or an existing one works differently
- A safety or reliability improvement that changes the workflow
- A structural change to how projects are stored or registered

Minor tweaks (wording in docs, small bug fixes that don't change behavior) do not need a version bump.
