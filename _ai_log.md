# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-04-08** (Claude): Design and implement a proxy-sandbox for per-project Claude file is... → Claude Code is now structurally confined to project folders via a per-project deny list...
- **2026-04-11** (Claude): Explore Claude Code features being underused; implement per-project... → Per-project CLAUDE.md system fully deployed across 89 projects; both Claude Code and Co...
- **2026-04-14** (Codex): Upgrade `helpi 5` so handover compilation is driven by a structured... → `helpi 5` is now conceptually cleaner: `_ai_log.md` remains the source of truth, while ...
- **2026-04-15** (Claude): Build and fully test the submission pipeline (`submit.ps1` + `/subm... → Full submission pipeline verified end-to-end on `Pub_MIPEntropy_MPC`. Package `_submiss...
- **2026-04-16** (Claude): Improve agent-switching context (AGENTS.md auto-generation), add fe... → Agent switching (Claude ↔ Codex) is now fully automatic in both directions — AGENTS.md ...
- **2026-04-18** (Claude): Add a collaboration section to the infrastructure guide; then restr... → The infrastructure guide now tells a coherent lifecycle story from project creation (1)...
- **2026-04-19** (Claude): Improve token efficiency and communication speed; add model-switchi... → Three new helpi commands (17-19: cheatsheet, model-check toggle, Beamer slides with pre...
- **2026-04-19** (Codex): Draft a down-to-earth book concept on research life with AI, ground... → First book draft created and verified. It uses `infrastructure_full.html` as the runnin...
- **2026-04-22** (Codex): Link the AI_auto infrastructure project to its Overleaf project and... → `AI_auto` is now linked to the Overleaf project through a real `Overleaf_source/` clone...
- **2026-04-22 Close** (Codex): Close the AI_auto working session after linking Overleaf and prepar... → `AI_auto` is linked to Overleaf, the Overleaf clone is clean and synced, and `slides_ma...
- **2026-04-22** (Codex): Revise `slides_main_v2.tex` so the DTU quotes appear on the front p... → `slides_main_v2.tex` now starts with the title page plus DTU rule quote, followed direc...
- **2026-04-22** (Codex): Create a condensed 10-slide version of the DTU AI infrastructure me... -> New file `slides_main_v2_10slides.tex` exists locally with exactly 10 frames. It has no...
- **2026-04-22 Close** (Codex): Close the AI_auto slide-editing session after preparing the condens... -> The full V2 deck and the condensed 10-slide deck are in place. The Overleaf source repo...
- **2026-04-22** (Codex): Make Codex automatically use the project implied by the directory i... -> Future Codex sessions should infer the active project from the current working director...
- **2026-04-23** (Claude): Design discussion — AI log as a certificate of conduct; immutabilit... -> Identified five properties that would make the log certificate-grade (scope declaration...
- **2026-04-23** (Claude): Professionalise the infrastructure — log compression, /helpi comman... -> Infrastructure professionalised: log compression keeps `_ai_log.md` lean automatically;...

---

## Session 2026-04-24
**Agent:** Claude Sonnet 4.6
**Goal:** Design the paper project naming convention and onboarding guide for group rollout.
**Files touched:**
- `onboarding_paper_projects.md` — new; onboarding guide covering the `Pub_Topic_Driver` naming convention, Overleaf tagging, one-project-per-paper rule, and both the provision-on-creation and key-table paths for local folder linking.
**Outcome:** Convention settled as `Pub_Topic_YourInitials` (driver = the person keeping the paper moving, not the PI by default); two local-folder strategies documented: automatic provisioning for new papers, key-table linking for legacy papers.
**Next steps:**
- Build automatic local folder provisioning triggered by a new tagged Overleaf project
- Draft the group email pointing people to the onboarding guide
**Git ref:** be3aef6

---

## Session 2026-04-24
**Agent:** Claude Sonnet 4.6
**Goal:** Multiple infrastructure improvements: incremental session draft logging, collaborator handovers via Overleaf, environment map baked into agent configs, platform map auto-update at close, infrastructure v0.8 docs, GitHub push.
**Files touched:**
- `log_tool_use.ps1` — new PostToolUse hook; appends timestamped lines to `_session_draft.md`; takes `-Agent` param
- `known_issues.md` — new; full environment map with software inventory, key paths, drive map, and known platform issues
- `generate_handover.ps1` — now writes `_handover_JR.md` to `Overleaf_source/` for collaborator sharing
- `~/.claude/commands/close.md` — added step 0 (read session draft), step 3.2 (platform map update), step 3.5 (clear draft)
- `~/.claude/commands/work.md` — added step 1b (scan for collaborator handovers in Overleaf_source/)
- `~/.claude/settings.json` — PostToolUse hook wired to `log_tool_use.ps1 -Agent Claude`
- `~/.claude/CLAUDE.md` — platform facts block added; software locations, tool rules, em-dash PS5 warning
- `~/.codex/config.toml` — platform facts added; Codex-specific Unix-on-Windows rule
- `infrastructure.html` — bumped to v0.8; added §J (environment map), session draft subsection, collaborator handover subsections in §7 and §I, platform map auto-update subsection
- `helpi.cmd` — fixed `powershell` → `pwsh` (PS5 read UTF-8 as Windows-1252, causing em-dash bytes to close string literals)
- `push_to_github.ps1` — removed em-dashes from string literals; same root cause
**Outcome:** Session draft logging is live; collaborator handovers will appear in Overleaf after next helpi 2 push; environment map is baked into both agent configs and grows automatically at close; helpi.cmd PS5/UTF-8 encoding bug fixed.
**Next steps:**
- Test session draft hook fires correctly in next session
- Test `_handover_JR.md` generation on a paper project that has Overleaf_source/
- Roll out `Pub_Topic_Driver` naming convention to group — draft email using `onboarding_paper_projects.md`
- Build automatic local folder provisioning triggered by a new tagged Overleaf project
**Git ref:** 731ed64

---

## Session 2026-04-27
**Agent:** Codex
**Goal:** Add a GitHub-facing README and introduction for the AI_auto repository.
**Files touched:**
- `README.md` -- new; explains the purpose of AI_auto, the local-first research workflow, quick-start commands, repository layout, standard project folder structure, operating principles, and requirements.
- `_ai_log.md` -- appended this session entry.
**Outcome:** The GitHub repo now has a proper root README that introduces the infrastructure and explains what the main files and folders do.
**Next steps:**
- Push the README and log update to GitHub when ready.
**Git ref:** 6f6a1d5

---

## Session 2026-05-01
**Agent:** Claude Sonnet 4.6
**Goal:** Improve helpi 24 (one-pager) with a GUI file picker; fix project detection in /helpi; fix helpi 24 non-interactive (Claude Code) usage.
**Files touched:**
- `generate_onepager.ps1` — added Windows Forms pop-up picker (always shown in interactive terminals); added `-TexFile` param to bypass dialog when called non-interactively (e.g. from Claude Code); non-interactive context auto-picks `main.tex` or most-recently-modified file
- `helpi.ps1` — command 24 preview and execution now pass `-TexFile $texFile` when provided
- `~/.claude/commands/helpi.md` — rewrote: added 5-source project detection (explicit arg > conversation context > files touched this session > CWD > state file); added Step 2 pre-flight for command 24 (Claude lists Overleaf_source/, picks the .tex file, passes it explicitly)
**Outcome:** helpi 24 shows a GUI picker in a terminal and works headlessly in Claude Code; /helpi now infers the active project from conversation context rather than falling back to last-used.
**Next steps:**
- Test helpi 24 end-to-end in a real project session via /helpi
- Consider extending the GUI picker pattern to compile_latex.ps1 (helpi 6) which has the same multi-file ambiguity
**Git ref:** 52f3850

---

## Session 2026-05-04
**Agent:** Codex
**Goal:** Fix helpi 24 so non-interactive one-pager generation does not silently choose a manuscript when several candidates exist.
**Files touched:**
- `generate_onepager.ps1` -- changed manuscript discovery to prefer `main*.tex`, ignore generated table/response files, use a single candidate automatically only when unambiguous, and abort with explicit choices in non-interactive shells when several manuscript candidates exist.
- `helpi.ps1` -- updated command 24 help text to document the picker/explicit-file behavior.
- `_ai_log.md` -- logged this infrastructure fix.
**Outcome:** `helpi 24 Pub_StopGeometry_TBA` no longer auto-selects `main_R1.tex` in a non-interactive shell; it now lists `main_R1.tex` and `main_original.tex` and asks the caller to pass one explicitly. Interactive terminals still use the picker.
**Next steps:** Push AI_auto changes to GitHub when ready; use `helpi 24 Pub_StopGeometry_TBA main_R1.tex` for explicit regenerated one-pagers.
**Git ref:** 94bee02

---

## Session 2026-05-04
**Agent:** Codex
**Goal:** Make explanatory LaTeX source comments a standard part of helpi 24 one-pagers.
**Files touched:**
- `prompts/generate_onepager.md` -- added required non-compiling source comments: equation intuition, notation clarification, and policy reflection.
- `helpi.ps1` -- updated command 24 help text to document the source-comment standard.
- `_ai_log.md` -- logged this infrastructure update.
**Outcome:** Future one-pagers generated through `helpi 24` should include concise `% Intuition:`, `% Notation:`, and `% Policy reflection:` comments in the `.tex` source without changing the compiled one-page PDF.
**Next steps:** Push AI_auto changes to GitHub when ready.
**Git ref:** 94bee02

---

## Session 2026-05-04
**Agent:** Codex
**Goal:** Tighten helpi 24 one-pager style: plainer wording, numbered equations, and hidden explanations for unclear terms.
**Files touched:**
- `prompts/generate_onepager.md` -- added down-to-earth language requirements, numbered display-equation rule, and hidden-comment guidance for unclear terms and Bernoulli notation.
- `helpi.ps1` -- updated command 24 help text to mention plain language and numbered equations.
- `_ai_log.md` -- logged this infrastructure update.
**Outcome:** Future generated one-pagers should avoid dense unexplained terms, use numbered `equation` environments for major formulas, and explain necessary compact notation in non-compiling source comments.
**Next steps:** Push AI_auto changes to GitHub when ready.
**Git ref:** 94bee02
