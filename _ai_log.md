# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-06-25 (second session)** (Gemini 3.5 Flash (Medium)): Address NoteTaker watcher failures on the 20-minute test recording,... -> Handled the 18 MB test recording (transcript, Markdown, and LaTeX summaries written, PD...
- **2026-06-25 (third session)** (Claude): Three infrastructure tasks: (1) stop NoteTaker's free-tier Supabase... -> All three done, validated, committed and pushed. NoteTaker keep-alive is live (watcher ...
- **2026-06-30** (Claude): User asked whether CLI LLMs integrate with a symbolic math engine (... -> Established SymPy (not Z3) is the right fit for the actual need; Z3 considered but not ...
- **2026-06-30 (second session)** (Claude): Document the new `/verify-math` (SymPy) skill in the infrastructure... -> `/verify-math` is fully documented with an architecture report; SymPy flagged as an ins...
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

---

## Session 2026-08-18
**Agent:** Codex
**Goal:** Build a shorter, popular mathematical-verification deck with anonymous audits of three randomly supplied top-journal papers.
**Files touched:**
- `known_issues.md` -- marked infrastructure issues #43, #46, and #47 fixed after applying their documented repairs.
- `scripts/helpi.ps1` -- forwarded the optional Overleaf Git URL for `helpi 1` in preview and execution.
- `scripts/auto_handover.ps1` -- removed the leading UTF-8 BOM.
- `C:\Users\rich\.agents\skills\research-close\SKILL.md` -- corrected the handover-generator path.
- `presentations\verification\verification_talk_short.tex` -- new 16-slide popular Beamer deck; includes three anonymous paper audits, a joint four-paper audit table, and the optimization-library architecture; retains the original technical deck unchanged.
- `presentations\verification\verification_talk_short.pdf` -- compiled and visually checked output.
- `presentations\verification\audit_spotchecks.py` -- independent arithmetic checks for the anonymous audit slides.
- `presentations\verification\{Transpormetrica_B_test,PartB_test,PartC}.txt` -- text extracted from the three supplied PDFs for the internal audits.
**Outcome:** Delivered a 16-slide popular talk. The anonymous sample illustrates three distinct printed-formulation failures: reversed optimization direction; variance/standard-deviation confusion plus a contradictory proof; and disagreement between a stated dynamic objective and its Bellman recursion. A joint table reports correct checks and flags for all four papers without presenting targeted screens as full audits. A new architecture slide separates solver backends from independent verification oracles and explains that Gurobi is optional for selected MIPs, MIQPs, and exact benchmark bounds. Arithmetic spot checks pass, the deck compiles cleanly, and the new slides were visually inspected. Findings are explicitly limited to internal consistency because unavailable source code could silently correct the printed models.
**Next steps:** Rehearse for timing and decide whether to retain all three anonymous paper slides or move one to backup for a sub-15-minute slot.
**Git ref:** 7789853

---

## Session 2026-08-27
**Agent:** Claude Opus 5
**Goal:** Design and build an instruction set (skill) for refereeing and editing papers, so review decisions rest on verified findings rather than impression.
**Files touched:**
- `C:\Users\rich\.agents\skills\review-paper\SKILL.md` -- new /review-paper skill: 9 passes, 2 gates, hard rules (confidentiality, anchoring, defect-vs-preference, confidence markers, expertise boundary).
- `...\review-paper\references\checklist.md` -- dimensions D1-D12 plus 1-5 rubric anchors for C/R/D/E/P/Rp.
- `...\review-paper\references\review-paradigms.md` -- PRISMA 2020 / PRISMA-ScR / MOOSE branch for review and survey papers.
- `...\review-paper\references\voice.md` -- voice rules and calibration protocol for drafting the letter as the user.
- `...\review-paper\templates\review_to_authors.md`, `review_confidential.md` -- letter, confidential note, editor decision letter, reviewer brief.
- `JR\Reviews\_index.md`, `JR\Reviews\_voice\README.md` -- review register (rubric row per review) and voice-sample folder.
- `~\.claude\skills\review-paper` -- junction to the shared .agents copy.
**Outcome:** /review-paper is live. It extends the user's eight criteria with venue fit, claim-evidence alignment, identification, a complexity budget test (missing naive baseline is a MAJOR finding), uncertainty practice, reproducibility, arithmetic and cross-reference audit, reference integrity, salami-slicing, limitations honesty, and revision-round classification. Mechanical audit runs before judgment; a devil's-advocate pass precedes scoring; decision rule maps rubric to accept/minor/major/reject. Simple method on strong data is written in as a full contribution.
**Next steps:** (1) drop 2-3 past review letters into `JR\Reviews\_voice\` for voice calibration; (2) calibrate the rubric by running the skill on a paper already decided and comparing recommendations; (3) add /review-paper to `infrastructure.html` if it should appear in the helpi docs.
**Git ref:** ae23b09

---

## Session 2026-08-27
**Agent:** Claude Opus 5
**Goal:** Decide how QGIS should fit the JR structure, and implement it.
**Files touched:**
- `AI_auto\scripts\add_qgis.ps1` -- new, backs helpi 28. Discovers the QGIS install at run time (handles LTR and regular layouts), writes workspace-scoped `.vscode/settings.json`, `.env` and `qgis_smoketest.py` into a project, backs up existing files unless -Force.
- `AI_auto\scripts\helpi.ps1` -- registered command 28 at all four points (command array, contextual help, dry-run, dispatch).
- `AI_auto\known_issues.md` -- #50: the QGIS-as-a-tool convention plus the three PyQGIS traps.
- `~\.claude\CLAUDE.md` -- helpi table row 28 and a QGIS software fact.
- `JR\QGIS_dev\` -- deleted once the plumbing was preserved.
- `JR\Reviews\2026_JCYMR_Gao\`, `JR\Reviews\_index.md` -- first live /review-paper run (JCYMR-D-26-00038, major revision).
**Outcome:** QGIS is a per-project tool, not a project type. No standing QGIS folder: `helpi 28` adds the PyQGIS plumbing where a project needs maps and nothing anywhere else. Generated config verified against a scratch folder (9 providers, 747 algorithms, valid memory layer, 85 OGR drivers) and emits valid JSON, unlike the hand-written original. Committed on `feat/helpi-28-pyqgis`, not merged.
**Next steps:** (1) merge and push `feat/helpi-28-pyqgis`; (2) `helpi 16` so command 28 reaches infrastructure.html; (3) record the `gpd.datasets.get_path` deprecation at `Pub_StopGeometry_TBA\Code\visualize.py:393` in that project -- fig3 may be silently skipping; (4) `JR\Reviews\_voice\` is absent although last session logged creating it, so voice calibration is still unstarted.
**Git ref:** 08aab17

---

## Session 2026-08-27 (2)
**Agent:** Claude Opus 5
**Goal:** Install Biogeme for discrete choice, then make tool tracking survive a machine replacement.
**Files touched:**
- `scripts/tool_inventory.ps1` -- new, backs helpi 29. Probes 26 tools, rewrites TOOLS.md, read-only.
- `TOOLS.md` -- new, generated. Replaces the hand-maintained table that had drifted.
- `PROFILING.md` -- new. Profiling workflow, tools and traps.
- `IDEAS.md` -- new. Designed-but-unbuilt backlog; first entry is the dataflow visualiser.
- `INSTALL.md` -- Part B rewritten into four tiers with the install traps.
- `known_issues.md` -- #51 (Biogeme); software table replaced by a pointer to TOOLS.md.
- `scripts/helpi.ps1` -- helpi 29 registered at all four points.
- `~\.claude\CLAUDE.md` -- Biogeme entry, venvs-outside-OneDrive rule, helpi 29 row, profiling block.
- `C:\Users\rich\venvs\biogeme313\` -- new venv (850 MB) plus `biogeme_check.py`.
**Outcome:** Biogeme 3.3.4 installed outside OneDrive and validated against the published Swissmetro MNL (N=6768, LL -5331.252, all betas within 4e-3). Tool tracking is now generated rather than hand-maintained: three lists had drifted, the known_issues table being stale on four versions and missing ten tools including Gurobi. Profiling stack (scalene, py-spy, viztracer, pydeps, Graphviz) confirmed and made discoverable from global CLAUDE.md, without which a session would reach for cProfile and misattribute native time. Surveyed all 113 projects: found ortools imported at 68 sites but installed nowhere behind a silent PuLP fallback, and three R packages used but missing.
**Next steps:** (1) merge and push the branch, now 3 commits and misnamed `feat/helpi-28-pyqgis`; (2) pin the ortools/PuLP solver backend explicitly in Pub_MIPEntropy_MPC, Pub_PMIP_AOR, Pub_SAA_PMIP_MC -- installing ortools would silently change three papers' solver (same hazard as #45); (3) `install.packages(c("minpack.lm","openxlsx","reshape2"))` for Pub_NonlinearDiffusion_PartB; (4) `helpi 16` so commands 28/29 reach infrastructure.html; (5) consider pandoc for the .docx review workflow; (6) dataflow visualiser prototype, see IDEAS.md #1.
**Git ref:** 59176e1
