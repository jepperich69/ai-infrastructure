# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

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
- **2026-05-04** (Codex): Tighten helpi 24 one-pager style: plainer wording, numbered equatio... -> Future generated one-pagers should avoid dense unexplained terms, use numbered `equatio...
- **2026-05-08** (Claude): Create an anonymous Google Forms survey for an AI-assisted research... -> - Danish form created via Google Apps Script: "AI-assisteret forskning: praksis, infras...
- **2026-05-15** (Claude): AI infrastructure maintenance — fix helpi crash in Gemini, design a... -> All three agents (Claude, Codex, Gemini) now share session-management skills via ~/.age...
- **2026-05-16** (Claude): Complete the infrastructure session: commit remaining changes, desi... -> The infrastructure now has a full fix loop: /close logs new open issues with exact fix ...

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
**Git ref:** bd7595d

---

## Session 2026-05-16
**Agent:** Claude Sonnet 4.6
**Goal:** Fix Codex startup warnings — 16 SKILL.md files failing to load due to invalid YAML frontmatter.
**Files touched:**
- `~/.agents/skills/catch-up/SKILL.md` — added YAML frontmatter (`name`, `description`)
- `~/.agents/skills/close/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/family/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/snapshot/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/work/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/research-catch-up/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/research-close/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/research-family/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/research-snapshot/SKILL.md` — added YAML frontmatter
- `~/.agents/skills/research-work/SKILL.md` — added YAML frontmatter
- All 12 affected `SKILL.md` files — stripped UTF-8 BOM (root cause of Codex rejection)
- `~/.claude/projects/.../memory/feedback_ps1_encoding.md` — expanded to document BOM issue alongside curly-quote issue
- `AI_auto/known_issues.md` — added issue #11 (Edit/Write tool writes UTF-8 BOM)
**Outcome:** All 16 Codex SKILL.md warnings resolved; root cause was UTF-8 BOM prepended by the Edit tool, not missing frontmatter content per se.
**Next steps:** none
**Git ref:** 7b65077

---

## Session 2026-05-18
**Agent:** Claude Sonnet 4.6
**Goal:** Explore graphify skill feasibility; redesign session startup flow for speed.
**Files touched:**
- `~/.claude/commands/work.md` — added fast-load flow: reads `_state/current.md` by default; `--full` flag restores legacy full read of AI log + handover
- `~/.claude/commands/close.md` — added step 3.7: write `_state/current.md` state card (≤20 lines) after each session close
- `~/.claude/CLAUDE.md` — added `## Manuscript writing conventions` section (Eq. refs, Harvard cite, italic paragraph headers, intuition paragraphs after all proofs)
**Outcome:** Session startup redesigned around a ≤20-line state card; full history remains accessible via `--full` flag. Global manuscript writing conventions added.
**Next steps:** none
**Git ref:** 74fbcff

---

## Session 2026-05-20
**Agent:** Claude Sonnet 4.6
**Goal:** Explore mobile access options for research projects — discussing papers on the go.
**Files touched:**
- `~/.claude/settings.json` — added then reverted `remoteControlAtStartup: true` (kept manual)
**Outcome:** Claude Remote Control is the best mobile option; Termux+Gemini CLI blocked by Google Advanced Protection on user's phone.
**Next steps:**
- Use `claude remote-control` manually when needed; scan QR code from Claude Android app
- Gemini CLI voice extensions exist if Termux becomes available later (gemini-cli-voice-extension, gemini-tts-mcp)
**Git ref:** 3c60ad6

## Session 2026-05-21
**Agent:** Gemini CLI
**Goal:** Create a 20-slide presentation deck for the division meeting on AI infrastructure and working habits.
**Files touched:**
- Overleaf_source/slides_division_meeting.tex -- Created and iteratively refined the full slide deck (19 slides). Added TikZ graphics for fragmentation, integrated loops, multi-agent workflows, and folder structures. Incorporated strategic framing, DTU policy mandates, work-life balance rules, and researcher actionable next steps.
**Outcome:** A comprehensive, technically rich, and strategically framed 20-slide presentation is complete, compiled, and synced to Overleaf. It covers architecture, human adaptation, and institutional call-to-action.
**Next steps:** none
**Git ref:** f4175b2
