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
