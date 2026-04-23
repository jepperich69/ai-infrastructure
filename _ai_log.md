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
**Git ref:** cafb203

**Continued (same session, install docs):**
- `setup.ps1` — step 6/6 → 7/7; added Overleaf bulk-import offer at end of wizard
- `infrastructure.html` — new "Install" section: Scenario A (restore), Scenario B (new colleague), Overleaf bulk vs. one-by-one flow, prerequisites table; TOC entry added
- `setup_project.ps1` — hardcoded jsonPath fixed
- `setup_tagged.ps1` + `config.ps1` — tagTargets moved to config; encoding fix

---

## Session 2026-04-19
**Agent:** GPT-5 Codex
**Goal:** Draft a down-to-earth book concept on research life with AI, grounded in the full infrastructure guide and supported by current productivity and research-computing literature.
**Files touched:**
- `AI_auto/book_draft_researcher_ai_infrastructure.md` — created first full Markdown draft, working title "The Down-to-Earth AI Researcher"; includes book premise, AI Productivity Law, modern researcher infrastructure problem, API vs local/license discussion, Git/Overleaf pull-push chapter, logging/handover chapter, feeder-vs-RAG chapter, prompting guidance, paper-writing lifecycle, setup/install chapter, CV/public-record chapter, and working references.
- `AI_auto/_ai_log.md` — appended this session log entry.
**Outcome:** First book draft created and verified. It uses `infrastructure_full.html` as the running implementation example and cites literature including Noy and Zhang (2023), Brynjolfsson et al. (2023), Peng et al. (2023), Dell'Acqua et al. (2023), Lewis et al. (2020), Wilkinson et al. (2016), Wilson et al. (2017), and Overleaf Git documentation.
**Next steps:**
- Expand Chapter 1 into a polished opening chapter with the AI Productivity Law as the hook.
- Turn Chapters 3-6 into a concrete narrative around one fictional or real paper project moving through pull, local AI work, logging, close, and feeder linking.
- Add boxed end-of-chapter checklists: "What to implement this week", "What to avoid", and "What to automate later".
- Decide whether the book should live as Markdown, LaTeX, or HTML/PDF generated from the infrastructure docs.
**Git ref:** c2c80a8

---

## Session 2026-04-22
**Agent:** GPT-5 Codex
**Goal:** Link the AI_auto infrastructure project to its Overleaf project and make it work with the normal helpi project facilities.
**Files touched:**
- `AI_auto/Overleaf_source/` — created by cloning Overleaf git project `https://git.overleaf.com/69e4cd88646aa324de75fc2c`; current branch is `master`; contains `main.tex`, `main_v2.tex`, and `figures/`.
- `AI_auto/.gitignore` — added `Overleaf_source/` so the nested Overleaf git clone is not accidentally tracked by the infrastructure repo.
- `AI_auto/projects.json` — registered `AI_auto` with path `JR\AI_auto\Overleaf_source` and branch `master`, enabling `sync_one.ps1`, `push_to_overleaf.ps1`, snapshots, and other registry-based commands.
- `AI_auto/helpi.ps1` — added `AI_auto` to current-working-directory project detection.
- `AI_auto/open_project.ps1` — changed project-root resolution from `Publikationer\$Project` to shared `Resolve-ProjectRoot`, so `helpi 5 AI_auto` can find projects directly under `JR`.
- `AI_auto/compile_latex.ps1` — changed source-folder resolution to shared `Resolve-ProjectRoot`, so `helpi 6 AI_auto` can compile `AI_auto\Overleaf_source`.
- `AI_auto/generate_slides.ps1` — changed project-root resolution to shared `Resolve-ProjectRoot`, so `helpi 19 AI_auto` works for the infrastructure deck/project.
- `AI_auto/_ai_log.md` — appended this session log entry.
**Outcome:** `AI_auto` is now linked to the Overleaf project through a real `Overleaf_source/` clone and a `projects.json` entry. Verified `sync_one.ps1 -Project AI_auto`; it reports the project is already up to date with Overleaf. PowerShell parse checks passed for `helpi.ps1`, `open_project.ps1`, `compile_latex.ps1`, and `generate_slides.ps1`.
**Next steps:**
- Decide whether the technical-meeting slides should be developed in `AI_auto\Overleaf_source\main.tex` or `main_v2.tex`.
- Optionally run `helpi 6 AI_auto` once from the normal user shell to compile and open the Overleaf PDF.
- Existing uncommitted infrastructure changes predating this session remain present in `config.ps1`, `generate_handover.ps1`, `_feeders/`, and `book_draft_researcher_ai_infrastructure.md`.
**Git ref:** c2c80a8

**Continued (same session, DTU technical meeting slides):**
- `AI_auto/Overleaf_source/slides_main.tex` — created a 13-slide Beamer deck for the DTU technical meeting. The deck uses `infrastructure_full.html` as the operational source, includes `figures/Infra_frontpage.png`, and builds editable TikZ diagrams for Overleaf sync, sensitive-data boundaries, logging/handover, feeder projects, and the publication pipeline.
- `AI_auto/Overleaf_source/` — committed and pushed `slides_main.tex` to the linked Overleaf project (`master`, pushed `4216e7c..fb4534f`).
**Outcome:** A compressed 13-slide operational deck is now available in Overleaf as `slides_main.tex`. The deck deliberately does not use the `Pub_AI_Research_Book` book project or its `main_v2` draft. Local compile was attempted but blocked by MiKTeX first-time setup ("fresh TeX installation"); static source checks found no non-ASCII typography or obvious frame-count issues.
**Next steps:**
- Open the Overleaf project and compile `slides_main.tex`.
- Adjust slide density after seeing the PDF, especially slides 3, 6, 10, and 13 if they feel text-heavy.
- Add a screenshot/export of the live project network graph if a more visual feeder slide is needed.

**Continued (same session, first slide revision):**
- `AI_auto/Overleaf_source/slides_main.tex` — simplified the language throughout; removed the front-page image; replaced the DTU rule summary with the direct Danish quote; reframed the "real problem" slide as a normal research day; added the coding-assistant role explicitly; strengthened the productivity/competitiveness wording in plain English; clarified feeder updates through logs and handovers; added the DTU license question and noted that Copilot is useful but limited for this workflow.
- `AI_auto/Overleaf_source/.gitignore` — added `*.pdf` so generated PDFs are not committed from the Overleaf clone.
- `AI_auto/Overleaf_source/Pub_AI_Research_Book.pdf` — accidentally picked up by the first push because it was placed in the Overleaf Git folder; removed from Git tracking and pushed the cleanup while keeping the local file on disk.
**Outcome:** Revised slides were pushed to Overleaf. The Overleaf repo is clean at commit `e2d56cf`; the local PDF remains available but is ignored by Git.
**Next steps:**
- Recompile `slides_main.tex` in Overleaf and check whether the simplified slides remove the overlap problems.
- If overlap remains, the next likely fixes are to split slide 2 or reduce the TikZ diagrams further on slides 7, 9, 10, and 11.

**Continued (same session, slides_main_v2):**
- `AI_auto/Overleaf_source/slides_main_v2.tex` — created from the locally copied Overleaf slide source, including the new second-last "Installation Package" slide.
- `AI_auto/Overleaf_source/` — fetched and fast-forwarded to the current Overleaf master before pushing `slides_main_v2.tex`; pushed commit `abe0241`.
**Outcome:** `slides_main_v2.tex` is now available in Overleaf as a separate file, leaving `slides_main.tex` as the current Overleaf-edited version. The Overleaf clone is clean. A temporary Git stash named `preserve local slides_main before v2 push` remains in the Overleaf clone, but its relevant content is preserved in `slides_main_v2.tex`.
**Next steps:**
- Compile `slides_main_v2.tex` in Overleaf if you want to use the version with the installation-package slide.
- Drop the temporary stash later if it is no longer needed.

---

## Session 2026-04-22 Close
**Agent:** GPT-5 Codex
**Goal:** Close the AI_auto working session after linking Overleaf and preparing the DTU AI infrastructure slides.
**Files touched:**
- `AI_auto/Overleaf_source/` — linked to Overleaf project `https://git.overleaf.com/69e4cd88646aa324de75fc2c`; pushed `slides_main.tex` and later `slides_main_v2.tex`.
- `AI_auto/Overleaf_source/slides_main_v2.tex` — created a separate Beamer deck version with the installation-package slide as the second-last slide.
- `AI_auto/Overleaf_source/.gitignore` — added `*.pdf` so generated PDFs are not committed from the Overleaf clone.
- `AI_auto/projects.json` — registered `AI_auto` as a normal Overleaf-backed project.
- `AI_auto/helpi.ps1` — added `AI_auto` to current-working-directory project detection.
- `AI_auto/open_project.ps1`, `AI_auto/compile_latex.ps1`, `AI_auto/generate_slides.ps1` — changed project-root resolution to shared `Resolve-ProjectRoot` so projects under `JR\` work like projects under `Publikationer\`.
- `AI_auto/.gitignore` — ignored nested `Overleaf_source/` in the infrastructure repo.
- `AI_auto/_ai_log.md` — recorded the session work.
**Outcome:** `AI_auto` is linked to Overleaf, the Overleaf clone is clean and synced, and `slides_main_v2.tex` is available in Overleaf for the April 23 technical discussion. The main infrastructure repo still has existing uncommitted changes, including pre-existing changes outside this session.
**Next steps:** Compile `slides_main_v2.tex` in Overleaf, use it for the DTU meeting, then decide whether to clean up and test the installation package with a few real users before presenting it as a reusable workflow.
**Git ref:** c2c80a8

---

## Session 2026-04-22
**Agent:** GPT-5 Codex
**Goal:** Revise `slides_main_v2.tex` so the DTU quotes appear on the front page and the separate second slide is removed.
**Files touched:**
- `AI_auto/Overleaf_source/slides_main_v2.tex` — replaced the opening DTU-rule slide with a plain title/front page containing the two DTU quote paragraphs; removed the duplicate second DTU-rule slide and its "My reading" block.
- `AI_auto/_ai_log.md` — recorded this short slide-edit session.
**Outcome:** `slides_main_v2.tex` now starts with the title page plus DTU rule quote, followed directly by "A Normal Research Day". Static frame count is 13. The Overleaf source commit `d9affeb` was pushed to the linked Overleaf project.
**Next steps:** Recompile `slides_main_v2.tex` in Overleaf and check whether the title page quote block is visually comfortable; reduce the quote font or shorten the block if it feels too dense.
**Git ref:** d9affeb

---

## Session 2026-04-22
**Agent:** GPT-5 Codex
**Goal:** Create a condensed 10-slide version of the DTU AI infrastructure meeting deck without pushing it.
**Files touched:**
- `AI_auto/Overleaf_source/slides_main_v2_10slides.tex` — new 10-frame Beamer deck derived from `slides_main_v2.tex`; keeps the DTU quote title page and condenses the narrative by merging normal research work with motivation, combining browser-vs-agent material, and merging installation/publication support into one "What Exists Now" slide.
- `AI_auto/_ai_log.md` — recorded this short slide-edit session.
**Outcome:** New file `slides_main_v2_10slides.tex` exists locally with exactly 10 frames. It has not been committed or pushed.
**Next steps:** Compile `slides_main_v2_10slides.tex` in Overleaf, check density on slides 2, 3, and 9, then push if it is the version to use for the meeting.
**Git ref:** d9affeb

---

## Session 2026-04-22 Close
**Agent:** GPT-5 Codex
**Goal:** Close the AI_auto slide-editing session after preparing the condensed DTU meeting deck.
**Files touched:**
- `AI_auto/Overleaf_source/slides_main_v2.tex` — revised earlier so the DTU quotes sit on the front page and the duplicate second DTU-rule slide is removed.
- `AI_auto/Overleaf_source/slides_main_v2_10slides.tex` — new 10-slide condensed version for the meeting.
- `AI_auto/_handover.html`, `AI_auto/_handover.json`, `AI_auto/AGENTS.md` — updated by the user's `helpi 7` run before closing.
- `AI_auto/_ai_log.md` — recorded the slide edits and this close block.
**Outcome:** The full V2 deck and the condensed 10-slide deck are in place. The Overleaf source repo is clean at `0757ad8`; the AI_auto infrastructure repo has the handover updates from `helpi 7` pending locally.
**Next steps:** Compile `slides_main_v2_10slides.tex` in Overleaf, inspect slides 2, 3, and 9 for density, then push the deck if it is the meeting version to use.
**Git ref:** AI_auto `b822a06`; Overleaf_source `0757ad8`

---

## Session 2026-04-22
**Agent:** GPT-5 Codex
**Goal:** Make Codex automatically use the project implied by the directory it is opened in, matching the Claude Code habit.
**Files touched:**
- `C:\Users\rich\.codex\config.toml` — extended global Codex developer instructions so a session opened inside a `Pub_`, `Pro_`, or `PhD_` folder treats that folder as the active research project and loads `.claude/CLAUDE.md`, `_ai_log.md`, feeder state, and git status automatically.
- `C:\Users\rich\.codex\config.toml` — extended the `AI_auto` rule so opening Codex inside `AI_auto` starts an infrastructure-project session and reads `infrastructure.html`.
- `AI_auto/_ai_log.md` — recorded this global Codex habit change.
**Outcome:** Future Codex sessions should infer the active project from the current working directory, not only from pasted paths or explicit `/work` commands.
**Next steps:** Test by opening Codex directly inside a publication project folder and confirming it loads that project context before making changes.
**Git ref:** AI_auto `b822a06`

**Follow-up fix:** The PowerShell `codex` wrappers in `C:\Users\rich\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` and `C:\Users\rich\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` were still forcing `codex -C C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR` on launch. Changed both wrapper targets to `(Get-Location).Path`, so plain `codex` now forwards the current directory to Codex while explicit `codex -C <path>` still works.

**Follow-up note:** Verified that the active sensitive-data convention is the shared human-only folder `JR\Sensitive_Data\`, outside individual paper projects. Updated `slides_main_v2.tex` and `slides_main_v2_10slides.tex` so the project tree no longer shows `Sensitive_Data/` inside `Pub_XXX/`, and the sensitive-data boundary slide points to `JR/Sensitive_Data/`.
