# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-07-02 (close)** (Claude): Build the jr_optlib robustness system end-to-end, migrate the MIPEn... -> jr_optlib is a working, tested, committed shared library with the transport primitive f...
- **2026-07-02 (second session)** (Claude): Build the first slice of the code-robustness system designed last s... -> First slice complete and validated. `ipf_2d` vetted + CERTIFIED via matching-marginals ...
- **2026-07-02 (third session)** (Gemini CLI): Build a min-cost exact repair oracle for PopInt to verify if greedy... -> Proved via exact LP that exact integer repair for PopInt is mathematically impossible u...
- **2026-07-02 (Gemini CLI close)** (Gemini CLI): Extract and verify legacy heuristics (VSP SA, Set-Cover Ladder Burn... -> The optimization library jr_optlib is now fully operational, tested, and pushed to GitH...
- **2026-07-02 (fourth session)** (Gemini CLI): Extract Napsti block-coordinate NLP primitive and the Dijkstra + SU... -> The NLP fixed-point solver and routing (Dijkstra+SUE) were successfully extracted to th...
- **2026-07-02 (fifth session)** (Gemini CLI): Survey the paper codebases to identify missing algorithmic families... -> Successfully identified three major missing algorithmic families (Finite Horizon DP, Di...
- **2026-07-02 (sixth session)** (Claude): Verify the DP/choice/RL primitives Gemini (Agy) added to jr_optlib ... -> Agy's choice/dp/rl code was numerically correct but registered vetted with no oracle/te...
- **2026-07-03** (Gemini CLI (Gemini 3.1 Pro (High))): Establish automated, recurring Google Drive backups for AI_auto, No... -> Deployed a local background daemon that bypasses DTU Task Scheduler restrictions. It si...
- **2026-07-03 (2)** (Claude Fable 5): Discuss a portfolio "helicopter view" (surface unexploited/dormant ... -> Decided the helicopter view is NOT a RAG (36 logs, 278 KB, fits in context) but an agen...
- **2026-08-14** (Claude Opus 5): Build a presentation on how we do mathematical verification and cer... -> Deck delivered. Section 5 is a real run, not a mock-up: Kahneman & Tversky (1979) check...
- **2026-08-18** (Codex): Build a shorter, popular mathematical-verification deck with anonym... -> Delivered a 16-slide popular talk. The anonymous sample illustrates three distinct prin...
- **2026-08-27** (Claude Opus 5): Design and build an instruction set (skill) for refereeing and edit... -> /review-paper is live. It extends the user's eight criteria with venue fit, claim-evide...
- **2026-08-27** (Claude Opus 5): Decide how QGIS should fit the JR structure, and implement it. -> QGIS is a per-project tool, not a project type. No standing QGIS folder: `helpi 28` add...
- **2026-08-27 (2)** (Claude Opus 5): Install Biogeme for discrete choice, then make tool tracking surviv... -> Biogeme 3.3.4 installed outside OneDrive and validated against the published Swissmetro...
- **2026-09-03** (Claude Opus 5): Make math render legibly in the Claude Code terminal instead of raw... -> Two-tier math display. The claude-math plugin (third-party, model-invoked skill, no exe...
- **2026-09-03** (Claude Opus 5): Get voice input working in the Claude Code CLI, expected to need a ... -> No plugin needed or possible. Dictation is native since v2.x (`/voice`, hold or tap); p...

---

## Session 2026-09-03
**Agent:** Codex
**Goal:** Strengthen the `review-paper` skill against ghost references and citations that do not support the claims where they appear.
**Files touched:**
- `~\.agents\skills\review-paper\SKILL.md` -- added an exhaustive reference-integrity harness covering citation-graph closure, DOI resolution, DOI-to-title/publication/author/year matching, identity classifications, claim-support classifications, escalation rules, a required audit table, and revision-round behavior.
- `~\.agents\skills\review-paper\references\checklist.md` -- made exhaustive reference identity and risk-based claim-support checks explicit in D3.
- `_ai_log.md` -- recorded this session.
**Outcome:** Full reviews and revision rounds must now verify every bibliography entry rather than sample references. Each DOI must resolve to metadata matching the cited title and publication; load-bearing and high-risk citations must also be checked in context and classified as supporting, partially supporting, unsupported, or unverifiable.
**Next steps:** Exercise the harness on the next full or revision review and refine only if the resulting audit is too costly or produces ambiguous classifications.
**Git ref:** 2b4085b

---

## Session 2026-09-04
**Agent:** Claude Opus 5
**Goal:** Stop the CLI agents from producing long, hard-to-digest answers; make short answers with drill-down offers the default across Claude, Codex and Gemini.
**Files touched:**
- `~\.claude\CLAUDE.md` -- new section "Answer length and drill-downs" after Communication style. Conclusion first, under ~150 words of prose, max 5 one-line bullets, cite `file.py:42` instead of pasting code, report results not process, close with one optional `Drill down: (a)... (b)... (c)...` line. Full length reserved for written deliverables, explicit requests for detail, and irreversible actions.
- `scripts\generate_handover.ps1` -- same rule injected into the generated AGENTS.md, ahead of the writing-style block, so Codex and Gemini inherit it. ASCII only; parse-checked.
- `AGENTS.md` in all 41 projects under `JR\` -- regenerated.
- `~\.claude\projects\...\memory\feedback_answer_length.md` + MEMORY.md index entry.
**Outcome:** The rule is live for all three CLIs everywhere. Regeneration ran `generate_handover.ps1` per project directly rather than `helpi 7`, so no session-log entries were written and no browsers opened; only AGENTS.md, `_handover.html` and `_handover.json` were rebuilt from each `_ai_log.md`. Checked first that no AGENTS.md was hand-written before overwriting: all 38 existing ones carried the auto-generated marker. Three projects had none and got one: `Ansoegninger\RSO electric`, `Projekter - JHR Privat\BertramVO`, `Publikationer\Reviews\JCYMR_26_28`.
**Next steps:** Optional, add the rule to the per-project `.claude/CLAUDE.md` template so new projects carry it at creation. Pre-existing latent bug found and left alone: `scripts\generate_handover.ps1:200` has an em-dash inside a PowerShell string literal, the exact encoding trap in the global platform rules. Backlog otherwise unchanged, see `_state/current.md`.
**Git ref:** e79b5a2

---

## Session 2026-09-04
**Agent:** Codex
**Goal:** Bring the infrastructure guide and GitHub README up to date, replace the stale versioned cover, regenerate the documentation, and commit the release.
**Files touched:**
- `infrastructure.html` -- updated through helpi 29; added current shared skills, research tools, source persistence, NoteTaker, and deliberate commit guidance; fixed NoteTaker placement and summary pagination.
- `README.md` -- updated commands, capabilities, operating principles, and stale script links.
- `Infra_frontpage.png` -- replaced with a simple version-neutral generated cover.
- `VERSION`, `CHANGELOG.md` -- released v1.1 and recorded the documentation update.
- `infrastructure_full.pdf` -- regenerated and visually verified; summary HTML/PDF outputs were also regenerated locally.
**Outcome:** The guide now reflects the September 2026 infrastructure. The full PDF has a clean version-neutral cover, and the printable desk reference renders in two pages without overflow. The GitHub README now presents AI_auto as general project infrastructure, with research as its most developed application rather than its boundary.
**Next steps:** Keep `TOOLS.md` generated through `helpi 29`; update this guide when a new helpi command or material shared skill is added.
**Git ref:** 7c35c92

---

## Session 2026-09-11
**Agent:** Claude Opus 5
**Goal:** Fold a "Natural Academic Writing" rule set (anti-LLM vocabulary and phrasing) into the research writing style, merge in earlier complaints, and make the rules apply to every text edit rather than only to style passes.
**Files touched:**
- `~\.claude\CLAUDE.md` -- "Research writing style" section rewritten: scope paragraph (every sentence touched for any reason, not only style passes), banned AI vocabulary list, banned stock phrases, cut-list with em-dash connectors, bold headers, three-item rhetorical lists, rhetorical inflation, and a mandatory final anti-LLM pass.
- `literature\Reference_Papers\STYLE_GUIDE.md` -- same scope paragraph in the intro; banned-phrase table extended with 25 rows and substitutions; new section "Natural academic writing (anti-LLM pass)" before "Tone".
- Claude memory (`project_writing_style_guide.md`, `MEMORY.md`) -- records the expansion and the rule to add any new complaint to both files.
**Outcome:** The style rules now name the AI tells explicitly (load-bearing, aware-compounds, robust without technical meaning, leverage, delve, pivotal, etc.), list banned stock phrases, and state that a content edit introducing a banned word, an em-dash connector, or a bold header is a defective edit even when the content is right. `/style-edit` reads the banned list generically, so it picks up the expansion without changes.
**Next steps:** Optional: add the writing-scope rule to the per-project `.claude/CLAUDE.md` template and to `scripts\generate_handover.ps1` so Codex and Gemini get it via AGENTS.md. Backlog otherwise unchanged, see `_state/current.md`.
**Git ref:** 0edf448

---

## Session 2026-09-13
**Agent:** Claude Opus 5
**Goal:** Recalibrate the research writing style guide against the author's own published papers instead of the classic reference set alone, and record the choices so later edits cannot silently reverse them. Then apply the new rules to a live manuscript as the first test.
**Files touched:**
- `literature/Reference_Papers/STYLE_GUIDE.md` -- rewritten, +194/-87. New calibration target stated in the intro (the author's own voice with the AI tells removed; where the classics and the own papers conflict, the own papers win), five own papers listed as the primary reference, "Explain, do not compress" promoted to the first core principle above the old economy rule, permitted house vocabulary / limited / banned lists rebuilt from the corpus, substitution table, "Natural academic writing (anti-LLM pass)" section, and a new "Decision record (grilling session, 2026-09-13)" table holding 26 numbered picks.
- `literature/Reference_Papers/` -- five of the author's own papers added as the calibration corpus: Paulsen & Rich (2023, TR-B), Hipolito, Vandet & Rich (2022, Applied Energy), Borysov, Rich & Pereira (2019, TR-C), Rich (2020, Econometrics and Statistics), Rich (2024, Transportation).
- `literature/Reference_Papers/_own_samples.txt`, `_own_fulltext.txt` -- text extracts from those PDFs, used for the calibration and removed again once the guide was written.
- `~\.claude\CLAUDE.md` -- "Research writing style" section rewritten to match the guide: scope, sentence and paragraph shape, register and voice, the permitted connectives, structure, banned vocabulary and phrases, the replacement rule, mechanics, and the final pass. Saved 22:18.
- `~\.claude\skills\style-edit\SKILL.md` -- touched at 22:19, immediately before the run. No diff is available, the `scripts/_claude_backup` mirror is gitignored and carries the same timestamp as the live file.
**Outcome:** The guide is now calibrated on the author's own five papers rather than on Einstein, Akerlof, Kahneman & Tversky, Ioannidis and Dantzig, which are demoted to a secondary reference for register and the concrete-example habit. The decision record fixes the contested calls in writing: Furthermore is un-banned, "In this paper, we" and the roadmap paragraph are allowed, Firstly/Secondly/Thirdly is the enumeration form, colon lists become separate sentences, consequence openers must name their subject, the Latinate verbs (circumvent, render, entail, accommodate, employ, exhibit) stay, paragraphs run 6 to 10 sentences, and the length rule is structural rather than a word count. The replacement rule is the operative addition: a rewrite may not introduce a non-technical word that is absent from the author's own papers, which is what stops a banned-word fix from flattening the register. The guide was then exercised on `Pub_SAA_PMIP_MC` (see that project's log, session 2026-09-13): 71 edits over 61 paragraphs in 24 sections, and the run surfaced no rule that needed changing. Neither session was logged before the window closed, so both entries are written retrospectively on 2026-09-14.
**Next steps:** Still open and unchanged from 09-11: add the writing-scope rule and the answer-length rule to the per-project `.claude/CLAUDE.md` template and to `scripts\generate_handover.ps1`, so Codex and Gemini inherit both through AGENTS.md; AI_auto itself still has no `.claude/CLAUDE.md`. Also consider putting the style-edit rule-count table into the `/style-edit` output template for every project, it made the 09-13 run reviewable at a glance. Backlog otherwise unchanged, see `_state/current.md`.
**Git ref:** 31afb12
