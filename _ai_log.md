# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-06-30 (third session)** (Claude): Fix the stale-PDF bug in `generate_docs.ps1` (helpi 16) surfaced la... -> Fix validated with Edge open (the exact failure condition) -- the output PDF now contai...
- **2026-07-02** (Claude): Design (not yet build) a general code-robustness system for Jeppe's... -> Design phase complete and agreed. No infrastructure code written yet -- this was a scop...
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

---

## Session 2026-09-03
**Agent:** Claude Opus 5
**Goal:** Make math render legibly in the Claude Code terminal instead of raw LaTeX.
**Files touched:**
- `~\.claude\skills\verify-math\scripts\render_math.py` -- new. SymPy 2D pretty-printer; importable by verify.py and usable standalone via `-c "<expr>"`.
- `~\.claude\skills\verify-math\SKILL.md` -- renderer wired into Step 3 and the report spec; new `## Rendered equations` section; failures now show the rendered form beside the SymPy source.
- `~\.claude\CLAUDE.md` -- new "Math display in the terminal" section (global rule, loads unconditionally).
- `~\.claude\settings.json`, `~\.claude\plugins\` -- claude-math@vladimirrott v0.6.0 installed, user scope, pinned to 76418df.
- memory: `project_claude_math_plugin.md` (new), `project_verify_math_skill.md`, `MEMORY.md`.
- No AI_auto project files changed this session.
**Outcome:** Two-tier math display. The claude-math plugin (third-party, model-invoked skill, no executables) emits inline Unicode glyphs; a new SymPy 2D renderer handles displayed equations -- stacked fractions, sums with limits, tall integrals, matrix brackets -- and is wired into /verify-math so reports read as mathematics rather than as SymPy source. Established that inline glyph rendering is impossible in this TUI: terminals do support Sixel/kitty graphics, but Claude Code repaints its own buffer and clobbers injected sequences; out-of-band rendering is the only route and stays unbuilt. Three traps found by testing and encoded in the tool: SymPy rejects Symbol *subclasses* as sum/integral limits, so subscripted names are detected by regex up front; bare names must default to Symbols because N, E, I, S, Q, beta and gamma are SymPy exports that would otherwise silently bind a user's variable to a builtin and render wrong mathematics without erroring; `Eq(lhs, rhs)` collapses to False when the sides differ structurally, so equations need `evaluate=False`.
**Next steps:** Unchanged from 2026-08-27 -- see `_state/current.md` for the carried backlog. New and optional: trial the VS Code extension `nuriyev.claude-code-katex` for true glyph rendering, or build the KaTeX side-pane; neither started.
**Git ref:** 7e974e0

---

## Session 2026-09-03
**Agent:** Claude Opus 5
**Goal:** Get voice input working in the Claude Code CLI, expected to need a Whisper plugin.
**Files touched:**
- `known_issues.md` -- new entry #53: native `/voice`, its auth requirements, and the wrong-default-microphone trap with its two measurement pitfalls.
- System audio config -- default capture device switched from `Microphone (Webcam C170)` to `Microphone Array (Intel Smart Sound)`, all three roles.
- No AI_auto scripts or code changed.
**Outcome:** No plugin needed or possible. Dictation is native since v2.x (`/voice`, hold or tap); plugins run only after a prompt is submitted, so none can capture a microphone. Neither configured marketplace carries anything voice-related. The real fault was a device one: Windows had made a webcam mic the system default while the laptop array mic sat active and unused, which would have degraded transcription and looked like a model failure. Privacy consent was already `Allow` at all three levels including `NonPackaged`, the subkey that governs terminals. Switched the default via `IPolicyConfig` for eConsole, eMultimedia and eCommunications, then confirmed clean transcription end to end. Details and the diagnosis order are in known_issues #53.
**Next steps:** Optional, pin `"voice": { "enabled": true, "mode": "tap" }` in `~/.claude/settings.json`; the setting already persists without it. The AKG Ara USB mic is the best input on this machine and is currently unplugged, worth using for long dictation. Project backlog carried unchanged, see `_state/current.md`.
**Git ref:** 47fa1a7

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
**Outcome:** The guide now reflects the September 2026 infrastructure. The full PDF has a clean version-neutral cover, and the printable desk reference renders in two pages without overflow.
**Next steps:** Keep `TOOLS.md` generated through `helpi 29`; update this guide when a new helpi command or material shared skill is added.
**Git ref:** -
