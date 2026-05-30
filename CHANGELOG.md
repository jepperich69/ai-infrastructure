# Changelog — AI Research Infrastructure

All notable changes to this infrastructure are documented here.
A "change" is anything that affects how you or Claude interacts with the system.

---

## [v1.0] — 2026-05-30 — Professional repo structure: scripts/ subfolder, config.local.ps1 split, helpi 26 update

**Repository restructure**
- All 34 PS1 scripts moved from the root to `scripts/` via `git mv` (history preserved).
- `helpi.cmd` updated to call `scripts\helpi.ps1`; root `helpi.ps1` is now a thin shim for backward compatibility with existing shell profiles.
- `config.ps1` refactored: `$aiRoot = Split-Path $PSScriptRoot -Parent` so it correctly points to `AI_auto/` from `scripts/`.

**config.local.ps1 split (enables clean `git pull` for all users)**
- `scripts/config.ps1` no longer contains any user-specific paths. It loads `scripts/config.local.ps1` at runtime.
- `scripts/config.local.ps1` is gitignored — never tracked, never causes merge conflicts.
- `scripts/config.local.example.ps1`: template users copy and fill in.
- `scripts/setup.ps1` (helpi 21) now writes `config.local.ps1` instead of overwriting `config.ps1`.
- Users who clone the repo and run `helpi 21` once get a clean, conflict-free update path from that point on.

**helpi 26 — update command**
- `scripts/update.ps1` (new): runs `git pull origin master`, reports version change, and automatically fixes Claude Code hook paths in `~/.claude/settings.json` if they still point to the old root location.
- Wire: `helpi 26` or `helpi update`.

**.gitignore hardened**
- Added: `scripts/config.local.ps1`, `_ai_log.md`, `_ai_log_archive.md`, `_session_draft.md`, `_state/`, `projects.json`, `papers.csv`, `AGENTS.md`, `network.html`, `_handover.html`, `_handover.json`, `_pipelines/`, `_forums/`, `_style_edits/`, `_claude_backup/`.
- User data and generated files no longer risk git conflicts.

**~/.claude/settings.json**
- Hook paths updated from `AI_auto\X.ps1` to `AI_auto\scripts\X.ps1` for `log_tool_use.ps1`, `sync_claude_config.ps1`, `auto_commit_hook.ps1`.

---

## [v0.9] — 2026-05-29 — Convergence Forum, config backup, writing style guide, /close Haiku delegation

**Convergence Forum (helpi 25)**
- `run_forum.ps1`: new `-Stage` parameter (`draft` / `revision` / `final`) controls agent conservatism — draft allows full debate, revision restricts to surgical edits, final is defect-detection only. Wired into agent and moderator prompts and initial Blackboard state.
- `helpi.ps1`: `-Stage` passed through to `run_forum.ps1`; interactive stage-selection prompt (1–3) added when omitted.
- Forum agents now run in read-only plan mode (`--permission-mode plan` for Claude, `--approval-mode plan` for Gemini) — agents can never directly edit manuscript or code files.
- `helpi 25` and `/pipeline` granted blanket approval in `AGENTS.md` — run end-to-end without per-step confirmation across all agents.

**~/.claude/ backup and restore**
- `sync_claude_config.ps1` (new): `-Backup` mirrors `~/.claude/` (CLAUDE.md, settings.json, commands/, skills/, projects/*.md) to `_claude_backup/` on OneDrive + GitHub; `-Restore` reverses it.
- `~/.claude/settings.json`: `sync_claude_config.ps1 -Backup` wired as first Stop hook — backup runs automatically on every session end.
- `restore.ps1`: step 6 now auto-restores from `_claude_backup/` on a new machine if the folder is present, instead of just printing an error.

**Writing style guide**
- `literature/Reference_Papers/` (new folder): five reference papers added as style anchors — Einstein (1905), Akerlof (1970), Kahneman & Tversky (1979), Ioannidis (2005), Dantzig & Thapa.
- `literature/Reference_Papers/STYLE_GUIDE.md` (new): full style guide derived from those papers — core principles, banned-phrase table, structural patterns to avoid.
- `~/.claude/CLAUDE.md`: "Research writing style" section added with inline dos/don'ts. Applies to all projects and all Claude sessions automatically.
- `generate_handover.ps1`: "Writing style" section injected into `AGENTS.md` on every `helpi 7` regeneration. Codex and Gemini now receive the same style rules without being told each session.

**/close Haiku delegation**
- `~/.claude/commands/close.md` rewritten: Phase 1 (context gathering) stays on Sonnet; Phase 2 (all mechanical operations — log append, compress, state card, handover regeneration) runs via a Haiku subagent. Haiku works from a compact briefing prompt and does not reprocess the full conversation history. Result: /close is faster and ~12x cheaper per tool call for the mechanical steps.
- `~/.claude/settings.json`: new permission patterns added — `PowerShell($*)`, `PowerShell([System.*)`, `Edit/Write(AI_auto/*.ps1)` — eliminating approval prompts for encoding checks and .ps1 edits.

**Infrastructure guide**
- `infrastructure.html`: helpi 13-25 section updated (was 13-23); detail rows added for helpi 24 (technical one-pager) and helpi 25 (Convergence Forum); quick-ref heading corrected to 1-25.
- New subsection in §A: Writing style — reference papers (papers listed with rationale, wiring explained).
- New subsection in §A: Agent task delegation — Haiku vs. Sonnet (table of task types, /close delegation explained).
- `infrastructure_full.pdf` removed from `.gitignore` and now tracked in git — GitHub always has a readable copy. Rebuilt by `helpi 16`.

---

## [v0.8] — 2026-04-24 — Session draft logging, collaborator handovers, environment map

**Incremental session draft logging**
- `log_tool_use.ps1` (new): PostToolUse hook that appends a timestamped line to `_session_draft.md` after every Edit, Write, or Bash call. Crash-safe — survives abrupt session ends and is picked up by the next `/close`.
- `~/.claude/settings.json`: PostToolUse hook wired to `log_tool_use.ps1 -Agent Claude`.
- `/close` updated: reads `_session_draft.md` as authoritative file-touch list; deletes it after writing the session block.

**Collaborator handovers via Overleaf**
- `generate_handover.ps1`: now also writes `_handover_JR.md` to `Overleaf_source/` (compact markdown: goal, outcome, files, next steps). Syncs to Overleaf with the next `helpi 2` push.
- `/work` updated: scans `Overleaf_source/` for peer handover files (`_handover_*.md` not from JR) and surfaces them at session start.

**Environment map**
- `known_issues.md` (new): full environment inventory — software versions and paths, drives, key folders, known platform issues with fix recipes.
- `~/.claude/CLAUDE.md` and `~/.codex/config.toml`: compact "Platform facts" block added at the top of each — always loaded, zero file reads required.
- `/close` updated: automatically checks for new platform discoveries each session and adds the 1–2 most reusable to both the inline block and `known_issues.md`.

**Bug fixes**
- `helpi.cmd`: changed `powershell` → `pwsh`. PS5 reads UTF-8 files as Windows-1252 — the third byte of an em-dash (0x94) is `"` in that encoding, silently closing string literals and causing parser errors.
- `push_to_github.ps1`: removed em-dashes from string literals (same root cause, belt-and-suspenders fix).

**Documentation**
- `infrastructure.html` v0.8: added §J (environment map table + platform rules), session draft subsection in §7, collaborator handover subsections in §7 and §I, platform map auto-update subsection.
- `onboarding_paper_projects.md` (new): group onboarding guide for the `Pub_Topic_Driver` Overleaf naming convention.

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
