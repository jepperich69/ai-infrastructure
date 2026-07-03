# AI Session Log Archive - AI_auto

---

## Archived 2026-04-24 (1 entry)

- **2026-04-05** (Claude): Set up lightweight versioning for the AI infrastructure; implement ... → Infrastructure is now git-versioned (GitHub: jepperich69/ai-infrastructure), released a...


---

## Archived 2026-05-01 (2 entries)

- **2026-04-05 (evening)** (Claude): Consistency-cleanup pass on v0.2 based on GPT code review recommend... → v0.2 is now consistent across all docs and scripts; snapshot safety posture improved.
- **2026-04-07** (Claude): Auto-generate separate PDF and HTML exports for the 1-2 pager and t... → Running `helpi 16` (or `.\generate_docs.ps1`) now produces four files: a summary HTML/P...


---

## Archived 2026-05-08 (4 entries)

- **2026-04-08** (Claude): Design and implement a proxy-sandbox for per-project Claude file is... → Claude Code is now structurally confined to project folders via a per-project deny list...
- **2026-04-11** (Claude): Explore Claude Code features being underused; implement per-project... → Per-project CLAUDE.md system fully deployed across 89 projects; both Claude Code and Co...
- **2026-04-14** (Codex): Upgrade `helpi 5` so handover compilation is driven by a structured... → `helpi 5` is now conceptually cleaner: `_ai_log.md` remains the source of truth, while ...
- **2026-04-15** (Claude): Build and fully test the submission pipeline (`submit.ps1` + `/subm... → Full submission pipeline verified end-to-end on `Pub_MIPEntropy_MPC`. Package `_submiss...


---

## Archived 2026-05-16 (1 entry)

- **2026-04-16** (Claude): Improve agent-switching context (AGENTS.md auto-generation), add fe... → Agent switching (Claude ↔ Codex) is now fully automatic in both directions — AGENTS.md ...


---

## Archived 2026-05-16 (1 entry)

- **2026-04-18** (Claude): Add a collaboration section to the infrastructure guide; then restr... → The infrastructure guide now tells a coherent lifecycle story from project creation (1)...


---

## Archived 2026-05-16 (2 entries)

- **2026-04-19** (Claude): Improve token efficiency and communication speed; add model-switchi... → Three new helpi commands (17-19: cheatsheet, model-check toggle, Beamer slides with pre...
- **2026-04-19** (Codex): Draft a down-to-earth book concept on research life with AI, ground... → First book draft created and verified. It uses `infrastructure_full.html` as the runnin...


---

## Archived 2026-05-18 (1 entry)

- **2026-04-22** (Codex): Link the AI_auto infrastructure project to its Overleaf project and... → `AI_auto` is now linked to the Overleaf project through a real `Overleaf_source/` clone...


---

## Archived 2026-05-20 (1 entry)

- **2026-04-22 Close** (Codex): Close the AI_auto working session after linking Overleaf and prepar... → `AI_auto` is linked to Overleaf, the Overleaf clone is clean and synced, and `slides_ma...


---

## Archived 2026-05-21 (2 entries)

- **2026-04-22** (Codex): Revise `slides_main_v2.tex` so the DTU quotes appear on the front p... → `slides_main_v2.tex` now starts with the title page plus DTU rule quote, followed direc...
- **2026-04-22** (Codex): Create a condensed 10-slide version of the DTU AI infrastructure me... -> New file `slides_main_v2_10slides.tex` exists locally with exactly 10 frames. It has no...


---

## Archived 2026-05-22 (1 entry)

- **2026-04-22 Close** (Codex): Close the AI_auto slide-editing session after preparing the condens... -> The full V2 deck and the condensed 10-slide deck are in place. The Overleaf source repo...


---

## Archived 2026-05-22 (1 entry)

- **2026-04-22** (Codex): Make Codex automatically use the project implied by the directory i... -> Future Codex sessions should infer the active project from the current working director...


---

## Archived 2026-05-24 (4 entries)

- **2026-04-23** (Claude): Design discussion — AI log as a certificate of conduct; immutabilit... -> Identified five properties that would make the log certificate-grade (scope declaration...
- **2026-04-23** (Claude): Professionalise the infrastructure — log compression, /helpi comman... -> Infrastructure professionalised: log compression keeps `_ai_log.md` lean automatically;...
- **2026-04-24** (Claude): Design the paper project naming convention and onboarding guide for... -> Convention settled as `Pub_Topic_YourInitials` (driver = the person keeping the paper m...
- **2026-04-24** (Claude): Multiple infrastructure improvements: incremental session draft log... -> Session draft logging is live; collaborator handovers will appear in Overleaf after nex...


---

## Archived 2026-05-24 (5 entries)

- **2026-04-27** (Codex): Add a GitHub-facing README and introduction for the AI_auto reposit... -> The GitHub repo now has a proper root README that introduces the infrastructure and exp...
- **2026-05-01** (Claude): Improve helpi 24 (one-pager) with a GUI file picker; fix project de... -> helpi 24 shows a GUI picker in a terminal and works headlessly in Claude Code; /helpi n...
- **2026-05-04** (Codex): Fix helpi 24 so non-interactive one-pager generation does not silen... -> `helpi 24 Pub_StopGeometry_TBA` no longer auto-selects `main_R1.tex` in a non-interacti...
- **2026-05-04** (Codex): Make explanatory LaTeX source comments a standard part of helpi 24 ... -> Future one-pagers generated through `helpi 24` should include concise `% Intuition:`, `...
- **2026-05-04** (Codex): Tighten helpi 24 one-pager style: plainer wording, numbered equatio... -> Future generated one-pagers should avoid dense unexplained terms, use numbered `equatio...


---

## Archived 2026-05-24 (5 entries)

- **2026-05-08** (Claude): Create an anonymous Google Forms survey for an AI-assisted research... -> - Danish form created via Google Apps Script: "AI-assisteret forskning: praksis, infras...
- **2026-05-15** (Claude): AI infrastructure maintenance — fix helpi crash in Gemini, design a... -> All three agents (Claude, Codex, Gemini) now share session-management skills via ~/.age...
- **2026-05-16** (Claude): Complete the infrastructure session: commit remaining changes, desi... -> The infrastructure now has a full fix loop: /close logs new open issues with exact fix ...
- **2026-05-16** (Codex): Diagnose and self-fix any obvious AI_auto infrastructure issue. -> `helpi 13` now prints a clean dashboard header, `helpi 15` warns cleanly when browser o...
- **2026-05-16** (Claude): Fix Codex startup warnings — 16 SKILL.md files failing to load due ... -> All 16 Codex SKILL.md warnings resolved; root cause was UTF-8 BOM prepended by the Edit...


---

## Archived 2026-05-24 (1 entry)

- **2026-05-18** (Claude): Explore graphify skill feasibility; redesign session startup flow f... -> Session startup redesigned around a ≤20-line state card; full history remains accessibl...


---

## Archived 2026-05-25 (1 entry)

- **2026-05-20** (Claude): Explore mobile access options for research projects — discussing pa... -> Claude Remote Control is the best mobile option; Termux+Gemini CLI blocked by Google Ad...


---

## Archived 2026-05-26 (2 entries)

- **2026-05-21 (Gemini CLI)** (Gemini CLI): Create a 20-slide presentation deck for the division meeting on AI ... -> A comprehensive, technically rich, and strategically framed 20-slide presentation is co...
- **2026-05-21** (Claude): Design and build a `/pipeline` skill — background multi-agent job (... -> `/pipeline` skill is live; slide deck updated with circular workflow diagram and new pi...


---

## Archived 2026-05-26 (1 entry)

- **2026-05-22** (Claude): Make `/close` skill run fully autonomously — no permission prompts ... -> `/close` now executes all steps without user confirmation; all session-management file ...


---

## Archived 2026-05-27 (1 entry)

- **2026-05-22b** (Claude): Patch `/close` skill — fix two bugs causing redundant stops during ... -> `/close` skill no longer errors on bash `$null` redirect or write-without-read on `_sta...


---

## Archived 2026-05-27 (1 entry)

- **2026-05-24** (Claude & Codex): Implement and verify the 'Convergence Forum' infrastructure for mul... -> Implemented `run_forum.ps1` and integrated it into the `helpi` command set. Codex audit...


---

## Archived 2026-05-29 (1 entry)

- **2026-05-24b** (Codex): Audit the newly implemented Convergence Forum infrastructure for ar... -> Audit found that `run_forum.ps1` is not yet operational due to a PowerShell parse error...


---

## Archived 2026-05-29 (1 entry)

- **2026-05-24c** (Codex): Patch and document the Convergence Forum issues found in the Codex ... -> The Convergence Forum now parses cleanly, rejects invalid agent lists before creating r...


---

## Archived 2026-05-29 (1 entry)

- **2026-05-24d** (Codex): Prepare Gemini's independent verification prompt for the patched Co... -> Wrote a Gemini audit instruction set covering PowerShell correctness, Blackboard integr...


---

## Archived 2026-05-29 (1 entry)

- **2026-05-24e** (Claude (Convergence Forum)): Live test run of the Convergence Forum on a low-stakes "test task" ... -> Forum ran and terminated cleanly. The test task completed in 3m 35s. The forum reached ...


---

## Archived 2026-05-30 (1 entry)

- **2026-05-24f** (Gemini CLI): Audit Convergence Forum and update division meeting slides. -> Forum infrastructure audited as READY. Slide update failed due to persistent syntax err...


---

## Archived 2026-05-30 (1 entry)

- **2026-05-24g** (Codex): Clean the broken division meeting slide deck, verify compilation, a... -> Slides 13-14 are structurally clean and the referenced `figures/Human-AI_Integration_Di...


---

## Archived 2026-05-31 (1 entry)

- **2026-05-24h** (Codex): Refine Convergence Forum slides and remove the MiKTeX compile blocker. -> Slide revisions were committed and pushed to Overleaf. MiKTeX was initialized for the n...


---

## Archived 2026-05-31 (1 entry)

- **2026-05-24i** (Gemini CLI): Implement SAD (Single-Agent Debate) mode for the FORUM skill and up... -> SAD mode is now fully operational and documented. Slides are ready and verified. Global...


---

## Archived 2026-05-31 (1 entry)

- **2026-05-24j** (Codex): Apply requested wording edits to the division meeting slide deck. -> Deck edits applied and verified. `helpi 6 AI_auto -Force` produced a fresh 26-page PDF;...


---

## Archived 2026-06-03 (1 entry)

- **2026-05-24k** (Codex): Audit the new `helpi 25` Forum/code-audit command path. -> Audited `helpi.ps1`, `run_forum.ps1`, the new `prompts/code-audit.md` template, and For...


---

## Archived 2026-06-04 (3 entries)

- **2026-05-24l** (Codex): Patch the `helpi 25` Forum/code-audit issues found in audit. -> The direct `helpi 25 code-audit` shortcut now maps to the current/last project, forum r...
- **2026-05-24m** (Codex): Prepare Claude's final validation instruction for the patched `help... -> Claude now has a focused validation prompt for the last review stage of the Forum/code-...
- **2026-05-24n** (Codex): Close the AI_auto session after patching and handoff preparation. -> Session closed with the `helpi 25` code-audit patch and Claude final-validation prompt ...


---

## Archived 2026-06-08 (1 entry)

- **2026-05-24o** (Claude): Claude final validation of patched `helpi 25` command; live smoke t... -> Validation verdict READY; smoke test revealed the role-file `=== DIGEST ===` placeholde...


---

## Archived 2026-06-16 (1 entry)

- **2026-05-25c** (Gemini CLI (gemini-2.5-flash)): Create refined 'V2' leadergroup slides; simplify language and add l... -> --


---

## Archived 2026-06-17 (1 entry)

- **2026-05-25d** (Codex): Diagnose and patch Codex-only SAD failures in `helpi 25`. -> Codex-only SAD now works end to end from normal PowerShell. Final smoke test `verify if...


---

## Archived 2026-06-19 (1 entry)

- **2026-05-26** (Claude): Generate survey visualizations from questionnaire Excel data and wi... -> Six clean survey result slides added to the division meeting Beamer deck and successful...


---

## Archived 2026-06-22 (1 entry)

- **2026-05-27** (Claude): Document helpi 25, fix /close permission prompts, and harden the Co... -> helpi 25 is documented, /close now runs without permission prompts, and forum agents ca...


---

## Archived 2026-06-22 (1 entry)

- **2026-05-27b** (Claude): Add automatic backup and restore of `~/.claude/` so the AI infrastr... -> `~/.claude/` is now backed up to `_claude_backup/` (OneDrive + GitHub) on every session...


---

## Archived 2026-06-25 (3 entries)

- **2026-05-29** (Claude): Set up a writing style guide from classic reference papers to gover... -> Writing style guide created and wired into global CLAUDE.md; tested on a research parag...
- **2026-05-29c** (Claude): Fix `/close` to run without permission prompts -> Root cause identified: subagents spawned via `Agent` tool have an independent permissio...
- **2026-05-29d** (Claude): Fix remaining `/close` permission prompts after subagent removal -> Two root causes found and fixed: (1) `**` in the middle of Edit/Write glob patterns doe...


---

## Archived 2026-06-30 (1 entry)

- **2026-05-26b** (Claude): Add `-Stage` parameter to the Convergence Forum to prevent agents f... -> Forum agents now operate in surgical/defect-detection mode when `-Stage revision` or `-...


---

## Archived 2026-06-30 (1 entry)

- **2026-05-29b** (Claude): Extend infrastructure with Haiku-delegated /close, fix permission g... -> /close now delegates mechanical operations to a Haiku subagent; permission patterns ext...


---

## Archived 2026-06-30 (1 entry)

- **2026-05-30** (Claude): Add `/style-edit` skill for background LaTeX prose editing, then re... -> `/style-edit` skill added for autonomous background prose-style editing of LaTeX manusc...


---

## Archived 2026-07-02 (1 entry)

- **2026-05-30b** (Claude): Push v1.0 to GitHub, remove redundant root helpi.ps1 shim, and upda... -> v1.0 fully pushed to GitHub; documentation updated and regenerated to match the scripts...


---

## Archived 2026-07-02 (2 entries)

- **2026-05-31** (Claude): Fix auth bug in /style-edit and /pipeline skills (both used claude ... -> Both skills now use subscription auth correctly. 4-agent comparison (Sonnet/Haiku/Gemin...
- **2026-05-31b** (Claude): Harden and complete the /style-edit skill: parallel chunked process... -> /style-edit now runs reliably as parallel Gemini jobs with token tracking, bibliography...


---

## Archived 2026-07-02 (4 entries)

- **2026-05-31c** (Claude): Fix `helpi 23` (push_to_github.ps1) failing for AI_auto due to miss... -> `helpi 23 AI_auto` now works — falls back to project root, found existing GitHub remote...
- **2026-06-04** (Claude): Add em-dash style rule to global writing guidelines and memory. -> Em-dash clause-connector rule is now enforced globally in all research writing sessions...
- **2026-06-03** (Gemini CLI (gemini-2.0-pro-exp-02-05)): Fix \/style-edit\ skill discovery and naming convention for Gemini CLI -> \/style-edit\ and \/style-apply\ are now discoverable by Gemini CLI with the requested ...
- **2026-06-03b** (Codex GPT-5.5): Fix Codex skill discovery warning for `/pipeline`. -> Codex should no longer skip the `/pipeline` skill for invalid YAML.


---

## Archived 2026-07-02 (1 entry)

- **2026-06-03c** (Codex GPT-5.5): Fix `/style-edit` not being recognised after the custom skill rename. -> Gemini now lists `style-edit`, `style-apply`, and `pipeline` as enabled skills; the `.a...


---

## Archived 2026-07-03 (1 entry)

- **2026-06-08** (Claude): Fix `run_forum.ps1` failing in Round 2 with `error: unknown option ... -> Forum claude calls now pipe prompts via stdin; `---` in blackboard state can no longer ...


---

## Archived 2026-07-03 (1 entry)

- **2026-06-16** (Claude): Fix `run_forum.ps1` failing for projects outside the `Publikationer... -> Forum (helpi 25) now resolves projects in any subfolder under `JR/`, not only `Publikat...
