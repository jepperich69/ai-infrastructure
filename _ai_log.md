# AI Session Log — AI Infrastructure Project

---

## Session 2026-04-05
**Agent:** Claude Sonnet 4.6
**Goal:** Set up lightweight versioning for the AI infrastructure; implement a stable/develop branch model; act on GPT's code review findings.
**Files touched:**
- `CHANGELOG.md` — created; documents v0.1 and v0.2 releases with a running unreleased section
- `VERSION` — created; current value v0.2
- `RELEASING.md` — created; plain-language instructions for making a new release
- `infrastructure.html` — version field added to subtitle; new versioning section added at the bottom
- `.gitignore` — created; excludes logs/ and overleaf_projects.csv
- `snapshot.ps1` — removed silent auto-commit of dirty state before tagging; now aborts with a clear file list and commit/discard instructions
- `C:\Users\rich\.claude\CLAUDE.md` — added session length management section: Claude proposes ⚠ close+restart at ~20 exchanges on a natural break
**Outcome:** Infrastructure is now git-versioned (GitHub: jepperich69/ai-infrastructure), released at v0.2, with a working stable/develop branch model and the main operational footgun in snapshot.ps1 fixed.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch so it degrades gracefully in non-interactive shells (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` sourced by all scripts (v0.3 candidate)
**Git ref:** ee25caf

---

## Session 2026-04-05 (evening)
**Agent:** Claude Sonnet 4.6
**Goal:** Consistency-cleanup pass on v0.2 based on GPT code review recommendations.
**Files touched:**
- `RELEASING.md` — updated "Current state" to v0.2, rewired "Working toward" to v0.3, made VERSION the explicit single source of truth in release steps
- `infrastructure.html` — updated version string to v0.2 (with VERSION SOT note), fixed snapshot diagram label from "copy main.tex" to "git tag full Overleaf_source/", fixed snapshot workflow description from "saves main.tex as frozen copy" to "git-tags full Overleaf_source/ state"
- `snapshot.ps1` — tightened abort guidance: replaced single destructive `checkout -- .` suggestion with three labelled options (commit / stash / discard), stash marked reversible, discard marked PERMANENT
**Outcome:** v0.2 is now consistent across all docs and scripts; snapshot safety posture improved.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** 3a9143d

---

## Session 2026-04-07
**Agent:** Claude Sonnet 4.6
**Goal:** Auto-generate separate PDF and HTML exports for the 1-2 pager and the full infrastructure guide.
**Files touched:**
- `generate_docs.ps1` — created; reads infrastructure.html, splices two CSS variants into the @media print block, writes infrastructure_summary.html and infrastructure_full.html, then calls Edge headless to produce matching PDFs
- `helpi.ps1` — added command 16 "Generate docs (summary + full HTML/PDF)" wired to generate_docs.ps1; preview and bounds-check updated automatically via `$commands.Count`
- `.gitignore` — added the four generated output files (infrastructure_summary/full .html/.pdf) as gitignored artifacts
**Outcome:** Running `helpi 16` (or `.\generate_docs.ps1`) now produces four files: a summary HTML/PDF showing only the 1-2 pager and a full HTML/PDF showing the complete guide.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** 5c80af8

---

## Session 2026-04-08
**Agent:** Claude Sonnet 4.6
**Goal:** Design and implement a proxy-sandbox for per-project Claude file isolation; document DTU AI data policy compliance; set up shared Sensitive_Data folder.
**Files touched:**
- `new_project.ps1` — added `.claude/settings.json` scaffold step: denies reads from AI_auto, AppData, and ~/.claude on every new project
- `infrastructure.html` — added §7b (proxy-sandbox design, two-level deny rules, DTU policy compliance table, Sensitive_Data folder convention); updated project folder structure listing to include `.claude/settings.json`
- `infrastructure_summary.html` / `infrastructure_full.html` / `_summary.pdf` / `_full.pdf` — regenerated via `generate_docs.ps1`
- `C:/Users/rich/.claude/settings.json` — added global deny rule for `JR/Sensitive_Data/**`
- `JR/Sensitive_Data/code/` — folder created as shared human-only zone for sensitive source data and analysis scripts
**Outcome:** Claude Code is now structurally confined to project folders via a per-project deny list and a global block on the shared Sensitive_Data folder; DTU AI data policy compliance is documented in §7b as a structural property of the setup, not a matter of discipline.
**Next steps:**
- Write `Sensitive_Data/code/generate_testdata.py` — synthetic test data generator supporting CSV, Excel, and Access (.accdb) input; CSV output; profile-based sampling per column
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** a56d604

---

## Session 2026-04-11
**Agent:** Claude Sonnet 4.6
**Goal:** Explore Claude Code features being underused; implement per-project CLAUDE.md system; extend it to Codex; update infrastructure docs.
**Files touched:**
- `AI_auto/prompts/project_claude_md_template.md` — created; blank template for per-project Claude briefs
- `AI_auto/new_project.ps1` — added `.claude/CLAUDE.md` scaffolding step to project creation
- `AI_auto/infrastructure.html` — updated: handover tag manual→auto, /close description, Codex skill table, capability comparison table, worked example terminal output
- `~/.claude/CLAUDE.md` — added per-project auto-fill instruction (fills blank CLAUDE.md from manuscript at session start) and AGENTS.md convention note
- `~/.claude/commands/close.md` — added step 4 (CLAUDE.md sync) and step 5 (auto-regenerate handover via helpi 5)
- `~/.codex/skills/research-work/SKILL.md` — added step 2: read `.claude/CLAUDE.md` before `_ai_log.md`
- `~/.codex/config.toml` — added "Per-project brief" section to developer_instructions
- `89× <project>/.claude/settings.json` — scaffolded across all projects (proxy-sandbox deny rules)
- `89× <project>/.claude/CLAUDE.md` — scaffolded with placeholder template; 6 filled with real content
- `Pub_AssesTiming_Raoul_TBA/.claude/CLAUDE.md` — filled: R1 revision, Raoul co-author, call-option payoff fix, β notation, frozen sections
- `Pub_PMIP_AOR/.claude/CLAUDE.md` — filled: under review AOR, MH=probabilistic-inference, mh_swap_repair() location
- `Pub_MIPEntropy_MPC/.claude/CLAUDE.md` — filled: R1 ready to submit, 47 comments, Springer_R1B.tex active, Stage 4 MH
- `Pub_ActionSpace_NatComm/.claude/CLAUDE.md` — filled: NatComm R1B complete, 56+ label, SI numbering, kernel provenance
- `Pub_NapstiGranularity_TBA/.claude/CLAUDE.md` — filled: V6 complete, 4 contributions, S-shape explanation, 14-city dataset
- `Pub_PopInt_PartB/.claude/CLAUDE.md` — filled: TR Part B under review, floor/ceiling proof, submitted version frozen, cross-bib constraints
**Outcome:** Per-project CLAUDE.md system fully deployed across 89 projects; both Claude Code and Codex now read the same brief at session start, eliminating cold-start on agent switches; /close now auto-updates CLAUDE.md and auto-regenerates handover.
**Next steps:**
- Fill in `.claude/CLAUDE.md` for other projects as you work on them (auto-fill kicks in at first `/work`)
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** 8519688

---

## Session 2026-04-14
**Agent:** GPT-5 Codex
**Goal:** Upgrade `helpi 5` so handover compilation is driven by a structured AI-log parser, then update the infrastructure guide to reflect the new behavior.
**Files touched:**
- `AI_auto/ai_log_tools.ps1` — created shared AI-log parser utilities: parse markdown session blocks, identify the latest session by date, validate required fields, and expose a compact latest-session summary
- `AI_auto/generate_handover.ps1` — upgraded to use the shared parser; now compiles a latest-session snapshot, validates the newest log block, writes `_handover.html`, and emits a structured `_handover.json` sidecar
- `AI_auto/helpi.ps1` — renamed command 5 in the menu from “Generate handover document” to “Compile handover package from AI log”
- `AI_auto/infrastructure.html` — updated the AI logging / handover section, the command table, and the one-pager so they describe `helpi 5` as a compiler from `_ai_log.md` to `_handover.html` + `_handover.json`
**Outcome:** `helpi 5` is now conceptually cleaner: `_ai_log.md` remains the source of truth, while the handover is compiled from it through a shared parser layer rather than treated as a separate parallel artifact. The upgraded generator was verified end-to-end on `Pub_MIPEntropy_MPC`, including correct latest-session detection and a structured `files_touched` array in `_handover.json`.
**Next steps:**
- Consider routing future `/close` implementations through the same parser/writer layer so log writing and handover compilation share one canonical schema
- Decide whether `status.ps1`, feeder digests, and reviewer workflows should also consume `ai_log_tools.ps1` rather than parsing `_ai_log.md` ad hoc
- If this becomes part of a formal release, update `CHANGELOG.md` and bump `VERSION`

---

## Session 2026-04-15
**Agent:** Claude Sonnet 4.6
**Goal:** Build and fully test the submission pipeline (`submit.ps1` + `/submit` skill + `helpi 17`); fix all bugs discovered during live test on `Pub_MIPEntropy_MPC`; final editorial pass on `Springer_R1C.tex`.
**Files touched:**
- `AI_auto/submit.ps1` — created; 7-step submission assembly script: (1) compile with BIBINPUTS+BSTINPUTS, (2) front-page via Ghostscript, (3) inline bbl using `[regex]::Replace` MatchEvaluator, (4) submission zip (tex as `main.tex`), (5) blind manuscript (line-by-line author stripping + compile + zip), (6) latexdiff with CRLF normalisation + bbl inlining, (7) copy staged AI content. File naming convention: `Type_Author_Journal_Year_Rev.*` (e.g. `Manus_Rich_MPC_2026_R1.pdf`). Revision auto-detected from tex filename.
- `AI_auto/prompts/submit.md` — created; `/submit` skill prompt: generates cover letter, highlights, author statement into `_submit_staging/`, compiles PDFs, calls `submit.ps1`
- `AI_auto/prompts/submit_stage_ai.md` — created; AI-only staging prompt (generates 3 files, does NOT call `submit.ps1`); used by `helpi 17` via `claude -p`
- `AI_auto/helpi.ps1` — added command 17 "Build submission package"; command 17 block: checks for `_submit_staging/cover_letter.pdf`, calls `claude -p` with `submit_stage_ai.md` prompt if absent, then calls `submit.ps1`; fixed command count check to use `($commands | Measure-Object).Count`
- `AI_auto/infrastructure.html` — rewrote §6c: new file naming convention, blind manuscript section, 7-step assembly description, known-gotchas table (4 bugs), updated dependencies table, updated usage examples
- `Pub_MIPEntropy_MPC/Overleaf_source/Springer_R1C.tex` — editorial fixes: "We a method" → "We present a method"; `{llrrrr}` → `{llrrr}` in tab:ablation; "21. October" → "21 October"; expanded §2.2 with permutation enumeration table (3 of 6 candidates, cost + probability); added proof motivation paragraph to Appendix B (Theorem 2.1); added `\begin{remark}` before Theorem 2.2 attributing parts (a) and (c) to Carlier2017/PeyreCuturi2019
- `Pub_MIPEntropy_MPC/_submit_staging/cover_letter.tex` + `.pdf` — generated
- `Pub_MIPEntropy_MPC/_submit_staging/highlights.txt` — 5 bullets, all ≤85 chars
- `Pub_MIPEntropy_MPC/_submit_staging/author_statement.tex` + `.pdf` — generated
**Bugs found and fixed during live test:**
1. **BSTINPUTS not set** — bibtex could not find `spmpsci.bst` in `Overleaf_source/` → empty .bbl → no references anywhere. Fix: `$env:BSTINPUTS = "$sourceDir;..."` added alongside BIBINPUTS.
2. **CRLF/LF mismatch** — `Springer_R1B.tex` had 1964 CR characters (Windows), `Springer_R1C.tex` had 0 (Unix). Latexdiff saw every line as different, could not find anchors, silently dropped real changes. Fix: LF-normalised temp copies diffed; originals untouched.
3. **PowerShell `-replace` corrupts .bbl** — `$` in reference titles (math) interpreted as regex back-references, erasing bibliography content. Fix: `[regex]::Replace` with MatchEvaluator for all .bbl substitutions.
4. **diff.tex compiled from wrong folder** — compiled from `_submissions/` folder, missing `svjour3.cls` and figures. Fix: compiled from `Overleaf_source/`; temp files cleaned up in `finally` block.
**Outcome:** Full submission pipeline verified end-to-end on `Pub_MIPEntropy_MPC`. Package `_submissions/2026-04-15_MPC/` contains 10 correctly named files including blind manuscript, diff with references, and AI-generated documents. `helpi 17` now calls `claude -p` automatically when staging is empty, making it a single-command full pipeline.
**Next steps:**
- Update `CHANGELOG.md` and bump `VERSION` to v0.3 (submit pipeline is a meaningful new feature)
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (carried from v0.2)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (carried from v0.2)

---

## Session 2026-04-16
**Agent:** Claude Sonnet 4.6
**Goal:** Improve agent-switching context (AGENTS.md auto-generation), add feeder network visualization to infrastructure docs, integrate frontpage image, discuss packaging feasibility.
**Files touched:**
- `AI_auto/generate_handover.ps1` — added AGENTS.md generation: writes paper description (from `.claude/CLAUDE.md`), latest session snapshot, full log, and session-entry instructions to project root on every `helpi 5` / `/close`
- `AI_auto/infrastructure.html` — v0.2 → v0.3: added AGENTS.md subsection in §3, added interactive D3.js feeder network graph in §7 (41 nodes, 7 clusters, convex hulls, zoom/drag), updated §10 shared-context note, updated one-pager handover scenario, integrated `Infra_frontpage.png` as cover page (HTML + full PDF, print-only h1/subtitle hide, `page-break-after: always`)
- `AI_auto/infrastructure_full.html` / `infrastructure_summary.html` / `_full.pdf` / `_summary.pdf` — regenerated via `generate_docs.ps1`
**Outcome:** Agent switching (Claude ↔ Codex) is now fully automatic in both directions — AGENTS.md is regenerated on every close and auto-loaded by Codex; the infrastructure guide is visually richer with a cover page and an interactive feeder graph showing the full cross-project knowledge network.
**Next steps:**
- Consider packaging the infrastructure as a GitHub template repo + installer script for external use (discussed: parameterise paths via `config.ps1`, write a `setup.ps1`, Windows-first)
- Update `CHANGELOG.md` and bump `VERSION` to v0.3
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (carried)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (carried)
**Git ref:** 9c33350

---

## Session 2026-04-18
**Agent:** Claude Sonnet 4.6
**Goal:** Add a collaboration section to the infrastructure guide; then restructure all section numbers to align with helpi 1–16 ordering.
**Files touched:**
- `infrastructure.html` — major restructuring: (1) added Section I: Collaborative Setup documenting the git-layer vs. personal-layer split, collaborator onboarding steps, branch discipline, shared `_ai_log.md` across contributors, and Overleaf co-authoring; (2) renumbered all file-layer sections to match helpi 1–16 exactly (previously sections 1–5 covered helpi 2, 4, 7, 5/6 in wrong order); (3) reordered sections to follow the project lifecycle story: create → pull → push → compile → logging → snapshot → rollback → submit → reviewer → status/docs; (4) added four new dedicated sections: helpi 1 (Create new project), 8/9 (Snapshot & Rollback), 10/11/12 (Submit & Reviewer Loop), 13–16 (Status/Network/Docs); (5) switched AI infrastructure sections from numeric labels (6, 6b, 6c, 7, 7b, 8, 9) to letters A–G to avoid conflict with helpi numbers; (6) merged Part 3 (Codex) and the new collaboration section into one Part 3 (H–I); (7) fixed all remaining v0.2 references → v0.5; bumped subtitle to v0.5.
**Outcome:** The infrastructure guide now tells a coherent lifecycle story from project creation (1) to submission (10–12), section numbers match helpi exactly, AI sections are clearly separated with letters A–I, and the collaboration model (git as coordination layer, personal install per person) is documented.
**Next steps:**
- Update `CHANGELOG.md` and bump `VERSION` file to v0.5
- Update the one-pager desk reference section labels to reflect A–G / H–I lettering
- `helpi.ps1`: wrap PSConsoleReadLine in try/catch for non-interactive shell degradation (carried from v0.2)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (carried from v0.2)
**Git ref:** ddafd54

---

## Session 2026-04-19
**Agent:** Claude Sonnet 4.6
**Goal:** Improve token efficiency and communication speed; add model-switching awareness; add Beamer slide generation; overhaul infrastructure documentation.
**Files touched:**
- `helpi.ps1` — added commands 17 (Claude Code cheatsheet), 18 (toggle model-check), 19 (generate Beamer slides); added helper functions `Write-CheatRow`, `Show-ClaudeCheatsheet`, `Toggle-ModelCheck`; fixed Windows PS 5.1 parse errors (em-dash encoding, nested function, ampersand in strings)
- `generate_slides.ps1` — new script: safety-pulls from Overleaf, detects main .tex, interactive controls (duration/depth/audience/emphasis) or named preset (quick/seminar/public), calls Claude via `-p`, offers git commit + push
- `prompts/generate_slides.md` — new prompt: encodes all four control dimensions with explicit depth/audience/emphasis guides, Beamer output spec (16:9, Madrid theme, single self-contained file, backup slides after \appendix for deep-dive)
- `infrastructure.html` — (1) bumped to v0.6; (2) added TOC with anchor links after subtitle; (3) added section IDs throughout; (4) completed desk reference (was missing helpi 10-12 and 15-19); (5) completed section 13-19 table (was missing rows 17-19); (6) fixed stale v0.5 reference in versioning section; (7) redesigned overview diagram: file layer now on top as foundation, AI layer replaced cramped boxes with clean OPEN/WORK/CLOSE phase table; (8) updated quick reference title to helpi 1-19
- `VERSION` — bumped to v0.6
- `CHANGELOG.md` — added v0.6 entry; backfilled v0.3, v0.4, v0.5 entries to close the gap from v0.2
- `memory/feedback_model_assessment.md` — new memory file: instructs Claude to assess each task and suggest Haiku when appropriate (one-line prompt, user switches with /model)
- `memory/MEMORY.md` — new memory index
**Outcome:** Three new helpi commands (17-19: cheatsheet, model-check toggle, Beamer slides with presets). Claude now flags Haiku-suitable tasks before starting. Infrastructure documentation overhauled: TOC added, desk reference completed, section 13-19 table filled, overview diagram redesigned with file layer as foundation and a readable AI phase table replacing the old scattered command boxes.

**Continued (same session, v0.7 work):**
- `config.ps1` (new) — single source of truth for all machine-specific paths; all 22 scripts refactored to dot-source it
- `restore.ps1` (new, helpi 20) — 8-step recovery checker for replacement-machine scenario
- `setup.ps1` (new, helpi 21) — first-time setup wizard for new users/machines
- `setup_project.ps1` — fixed remaining hardcoded `$jsonPath` (line 21)
- `setup_tagged.ps1` — moved `$tagTargets` hashtable into `config.ps1`; fixed mojibake encoding in "Ansogninger"
- `infrastructure.html` — added helpi 20/21 to command table and desk reference; bumped to v0.7
- `VERSION` / `CHANGELOG.md` — bumped to v0.7

**Next steps:**
- Test `helpi 19` end-to-end on a real project
- Test `helpi 21` on a fresh machine or in a scratch profile
- `helpi.ps1`: wrap PSConsoleReadLine in try/catch for non-interactive shell degradation (carried from v0.2)
**Git ref:** 9e596fb
