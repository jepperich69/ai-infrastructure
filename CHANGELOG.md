# Changelog — AI Research Infrastructure

All notable changes to this infrastructure are documented here.
A "change" is anything that affects how you or Claude interacts with the system.

---

## [v0.7] — 2026-04-19 — Portable installation: config.ps1 refactor + install scripts

- **`config.ps1`** (new): Single source of truth for all machine-specific paths (`$pubRoot`, `$vscode`, `$miktexBin`, `$latexdiffScript`, `$strawberryPerl`, `$tagTargets`). All 22 scripts now dot-source this file instead of defining their own hardcoded paths.
- **`restore.ps1`** (new, helpi 20): 8-step checker for replacement-machine recovery — verifies Claude CLI, Git, MiKTeX, VS Code, PS profile, `~/.claude/` folder, scheduled task, and `projects.json`. Fixes what it can automatically.
- **`setup.ps1`** (new, helpi 21): First-time setup wizard for new users — collects publications root, git identity, detects tool paths, writes `config.ps1`, wires `helpi` into PS profile, registers auto-sync scheduled task.
- All scripts bulk-refactored: hardcoded `$aiRoot`/`$pubRoot`/`$vscode`/`$miktexBin` lines replaced with `. "$PSScriptRoot\config.ps1"`.
- **`infrastructure.html`**: helpi 20/21 added to command table and desk reference; quick reference heading updated to `helpi 1-21`.

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

## [v0.6] — 2026-04-19

### Token efficiency + Beamer slide generation

**New helpi commands**
- `helpi 17` — Claude Code in-session cheatsheet: prints all slash commands, custom skills, model IDs, and tips in one terminal view. Also callable as `! helpi 17` from inside a session.
- `helpi 18` — Toggle model-check on/off: enables/disables the behavior where Claude assesses each incoming task and suggests switching to Haiku when appropriate. Edits the memory file — persists to next session.
- `helpi 19` — Generate Beamer slides from paper: safety-pulls from Overleaf first, then asks four controls (duration / depth / audience / emphasis). Three presets skip the questions: `quick` (12 min conference), `seminar` (45 min deep-dive), `public` (30 min non-specialist). Writes `slides_main.tex` into `Overleaf_source/` and offers to push.

**New scripts and prompts**
- `generate_slides.ps1` — slide generation driver; handles Overleaf pull safety net, .tex file detection, interactive controls, preset resolution, and post-generation push offer.
- `prompts/generate_slides.md` — Claude prompt for slide generation; encodes all four control dimensions with explicit depth/audience/emphasis guides and Beamer output requirements.

**Behavioral change: model assessment**
- Claude now assesses each incoming task and flags it as Haiku-suitable before starting (one-line prompt, user switches with `/model`). Applies to: mechanical parsing, file reads, scaffolding, context loading. Sonnet for logs/handovers. Opus for reviewer responses and cover letters.

---

## [Unreleased] — develop

- `push_to_overleaf.ps1`: fixed push detection bug — now pushes existing unpushed commits correctly.

---

## [v0.5] — 2026-04-18

- `infrastructure.html` — major restructure: section numbers now match helpi 1–16 exactly; added collaboration section (git as coordination layer, personal install per person); AI sections relabelled A–I to avoid conflict with helpi numbers; lifecycle ordering (create → pull → push → compile → log → snapshot → rollback → submit → reviewer → status/docs).

---

## [v0.4] — 2026-04-18

- `helpi.ps1` — renumbered all commands 1–16 in lifecycle order; merged project creation steps.

---

## [v0.3] — 2026-04-15

- `submit.ps1` — 7-step submission assembly pipeline: compile, front-page, inline bib, submission zip, blind manuscript + zip, latexdiff, AI-staged content copy.
- `prompts/submit.md` + `prompts/submit_stage_ai.md` — AI prompts for cover letter, highlights, author statement generation.
- `generate_docs.ps1` — produces summary and full HTML/PDF exports of `infrastructure.html` via Edge headless.
- `generate_handover.ps1` — upgraded to use shared AI-log parser (`ai_log_tools.ps1`); now writes `_handover.html` + `_handover.json` sidecar.
- `ai_log_tools.ps1` — shared parser for `_ai_log.md` session blocks.

---

## [v0.2] — 2026-04-05

- `snapshot.ps1`: removed silent auto-commit of dirty state before tagging. Now aborts with a clear file list and instructions to commit or discard first. A snapshot should always capture a known, intentional state.

---

## When does a change deserve a new version?

- A new `helpi` command is added or removed
- An existing command's behavior changes in a way that would break current usage
- A new slash command is added or an existing one works differently
- A safety or reliability improvement that changes the workflow
- A structural change to how projects are stored or registered

Minor tweaks (wording in docs, small bug fixes that don't change behavior) do not need a version bump.
