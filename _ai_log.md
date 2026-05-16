# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

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
- **2026-04-24** (Claude): Design the paper project naming convention and onboarding guide for... -> Convention settled as `Pub_Topic_YourInitials` (driver = the person keeping the paper m...
- **2026-04-24** (Claude): Multiple infrastructure improvements: incremental session draft log... -> Session draft logging is live; collaborator handovers will appear in Overleaf after nex...
- **2026-04-27** (Codex): Add a GitHub-facing README and introduction for the AI_auto reposit... -> The GitHub repo now has a proper root README that introduces the infrastructure and exp...
- **2026-05-01** (Claude): Improve helpi 24 (one-pager) with a GUI file picker; fix project de... -> helpi 24 shows a GUI picker in a terminal and works headlessly in Claude Code; /helpi n...
- **2026-05-04** (Codex): Fix helpi 24 so non-interactive one-pager generation does not silen... -> `helpi 24 Pub_StopGeometry_TBA` no longer auto-selects `main_R1.tex` in a non-interacti...
- **2026-05-04** (Codex): Make explanatory LaTeX source comments a standard part of helpi 24 ... -> Future one-pagers generated through `helpi 24` should include concise `% Intuition:`, `...

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

---

## Session 2026-05-08
**Agent:** Claude Sonnet 4.6
**Goal:** Create an anonymous Google Forms survey for an AI-assisted research seminar.
**Files touched:**
- `google_forms_guide.html` — step-by-step HTML guide for manual Google Forms creation (fallback reference)
- `formular_script.js` — Apps Script source (local copy)
- `ai_seminar_qr.png` — QR code for the Danish form respondent link
**Outcome:**
- Danish form created via Google Apps Script: "AI-assisteret forskning: praksis, infrastruktur og fremtidige behov"
- English form also created: "AI-assisted research: practice, infrastructure and future needs"
- Both forms: 5 questions (spm 1+5 Checkboxes/multiple answers; spm 2+3+4 Multiple choice/single answer), all required, no email collected, no login required
- Danish respondent link: https://docs.google.com/forms/d/e/1FAIpQLSduhzPQnQv-P5s86Kx-EWAKQ1CjM-3asKno4cmTp_sQKKdE8g/viewform
- QR code saved as `ai_seminar_qr.png` in AI_auto
- Export: Responses tab > Google Sheets icon > Download as .xlsx
**How to recreate a form (Apps Script method):**
1. Go to script.google.com > New project
2. Paste the Apps Script code (keep strings short/concatenated to avoid line-wrap syntax errors)
3. Remove setRequireLogin() and setShowSummary() — not supported on consumer Gmail accounts
4. Click Run > authorize once > get link from View > Logs
**Known pitfalls:**
- Copying code from chat introduces real newlines inside strings -> SyntaxError
- setRequireLogin(false) throws on Gmail (non-Workspace accounts)
- setShowSummary() does not exist in current Apps Script API
- Drive MCP cannot create Forms or Apps Script projects directly
**Next steps:**
- Distribute Danish link + QR code to seminar participants
- Export responses after seminar: Responses tab > Google Sheets > Download .xlsx
**Git ref:** 8269078

---

## Session 2026-05-15
**Agent:** Claude Sonnet 4.6
**Goal:** AI infrastructure maintenance — fix helpi crash in Gemini, design and implement grill-paper/grill-edit skills, migrate session skills to shared ~/.agents/skills/, audit and harden platform error-correction log propagation to all agents.
**Files touched:**
- `helpi.ps1` -- wrapped PSConsoleReadLine::AddToHistory in try/catch to fix crash in non-interactive shells (issue #10)
- `known_issues.md` -- added issue #10 (PSConsoleReadLine crash)
- `infrastructure.html` -- added grill-paper/grill-edit to command table; rewrote Section H to cover shared agent skills and three-agent capability matrix
- `generate_handover.ps1` -- added complete helpi 1-24 table and platform facts block (R/Python paths, known_issues.md proactive read) to every generated per-project AGENTS.md
- `~/.agents/skills/research-work/SKILL.md` (+ alias `work/`) -- new shared session-open skill for Codex/Gemini/Claude
- `~/.agents/skills/research-close/SKILL.md` (+ alias `close/`) -- new shared session-close skill; step 3.2 updated to use known_issues.md as single source of truth
- `~/.agents/skills/research-snapshot/SKILL.md` (+ alias `snapshot/`) -- new shared snapshot skill
- `~/.agents/skills/research-family/SKILL.md` (+ alias `family/`) -- new shared feeder-registration skill
- `~/.agents/skills/grill-paper/SKILL.md` + `~/.claude/commands/grill-paper.md` -- new pre-submission stress-test skill with dual 0-10 grading (paper quality + author understanding), three-phase interview, persistent grill_log.md
- `~/.agents/skills/grill-edit/SKILL.md` + `~/.claude/commands/grill-edit.md` -- new edit-phase skill that works through grill_log.md issue by issue and records author decisions
- `~/.gemini/AGENTS.md` -- added shared skills table, complete helpi 1-24 table, proactive known_issues.md read instruction
- `~/.codex/config.toml` -- added complete helpi 1-24 table, changed known_issues.md reference to proactive read instruction
- `~/.claude/CLAUDE.md` -- added complete helpi 1-24 table
- `~/.claude/commands/close.md` -- synced step 3.2 to match shared skill (known_issues.md as single source of truth)
**Outcome:** All three agents (Claude, Codex, Gemini) now share session-management skills via ~/.agents/skills/, see platform facts and known_issues.md proactively in every context, have the complete helpi 1-24 table, and have access to grill-paper/grill-edit for pre-submission paper quality checks.
**Next steps:**
- Run helpi 7 AI_auto to regenerate handover after this close
- Consider installing remaining Matt Pocock skills in Codex/Gemini if useful
- Mistral Vibe CLI integration deferred until shared skills are stable
**Git ref:** 880512c

---

## Session 2026-05-16
**Agent:** Claude Sonnet 4.6
**Goal:** Complete the infrastructure session: commit remaining changes, design and implement /catch-up skill for proactive known-issue remediation, add status fields to known_issues.md.
**Files touched:**
- `generate_handover.ps1` -- committed platform facts block (platform paths + known_issues.md proactive read in every generated AGENTS.md)
- `known_issues.md` -- added Status: fields (platform-fact / fixed / open) to all 10 issues; updated "Adding new entries" section with format for open entries (Affects/Fix fields)
- `~/.agents/skills/research-catch-up/SKILL.md` (+ alias `catch-up/`) -- new skill: sweeps open issues, applies fixes, marks them fixed, commits
- `~/.claude/commands/catch-up.md` -- Claude command copy of the catch-up skill
- `~/.agents/skills/research-close/SKILL.md` + `~/.agents/skills/close/SKILL.md` + `~/.claude/commands/close.md` -- step 3.2 updated: new issues logged as open/platform-fact with Affects/Fix fields; prompt user to run /catch-up when open issue is logged
- `~/.gemini/AGENTS.md` -- added catch-up row to shared skills table
- `~/.codex/config.toml` -- added AI_auto session instruction to run /catch-up on open
- `~/.claude/CLAUDE.md` -- added catch-up instruction to AI infrastructure project detection section
**Outcome:** The infrastructure now has a full fix loop: /close logs new open issues with exact fix instructions, /catch-up sweeps them and applies fixes, known_issues.md is the single source of truth for all agents.
**Next steps:** none
**Git ref:** caca18d

---

## Session 2026-05-16
**Agent:** Codex
**Goal:** Diagnose and self-fix any obvious AI_auto infrastructure issue.
**Files touched:**
- `status.ps1` -- replaced a mojibake box-drawing dashboard separator with an ASCII separator so `helpi 13` renders cleanly in agent terminals.
- `helpi.ps1` -- made browser-opening commands best-effort so non-interactive shells warn instead of throwing on `Start-Process`.
- `ai_log_tools.ps1` -- fixed latest-session parsing so separators do not attach to `Git ref` and same-day sessions resolve by file order.
- `AGENTS.md`, `_handover.html`, `_handover.json`, `Overleaf_source/_handover_JR.md` -- regenerated handover context after the log/parser fixes.
- `_session_draft.md`, `_state/last_project.txt` -- refreshed by the handover command run.
- `_ai_log.md` -- logged this maintenance fix.
**Outcome:** `helpi 13` now prints a clean dashboard header, `helpi 15` warns cleanly when browser opening is blocked, and generated handovers identify the newest same-day session correctly.
**Next steps:** none
**Git ref:** pending
