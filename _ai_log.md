# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-05-31** (Claude): Fix auth bug in /style-edit and /pipeline skills (both used claude ... -> Both skills now use subscription auth correctly. 4-agent comparison (Sonnet/Haiku/Gemin...
- **2026-05-31b** (Claude): Harden and complete the /style-edit skill: parallel chunked process... -> /style-edit now runs reliably as parallel Gemini jobs with token tracking, bibliography...
- **2026-05-31c** (Claude): Fix `helpi 23` (push_to_github.ps1) failing for AI_auto due to miss... -> `helpi 23 AI_auto` now works — falls back to project root, found existing GitHub remote...
- **2026-06-04** (Claude): Add em-dash style rule to global writing guidelines and memory. -> Em-dash clause-connector rule is now enforced globally in all research writing sessions...
- **2026-06-03** (Gemini CLI (gemini-2.0-pro-exp-02-05)): Fix \/style-edit\ skill discovery and naming convention for Gemini CLI -> \/style-edit\ and \/style-apply\ are now discoverable by Gemini CLI with the requested ...
- **2026-06-03b** (Codex GPT-5.5): Fix Codex skill discovery warning for `/pipeline`. -> Codex should no longer skip the `/pipeline` skill for invalid YAML.
- **2026-06-03c** (Codex GPT-5.5): Fix `/style-edit` not being recognised after the custom skill rename. -> Gemini now lists `style-edit`, `style-apply`, and `pipeline` as enabled skills; the `.a...
- **2026-06-08** (Claude): Fix `run_forum.ps1` failing in Round 2 with `error: unknown option ... -> Forum claude calls now pipe prompts via stdin; `---` in blackboard state can no longer ...
- **2026-06-16** (Claude): Fix `run_forum.ps1` failing for projects outside the `Publikationer... -> Forum (helpi 25) now resolves projects in any subfolder under `JR/`, not only `Publikat...
- **2026-06-17** (Claude): Extend the AI infrastructure so any non-paper folder under `JR\` ge... -> Verified end-to-end with a throwaway test folder (`JR\_test_generic_project_DELETE_ME`,...
- **2026-06-19** (Claude): Fix Gemini CLI auth (broken by Google's OAuth deprecation for indiv... -> `gemini` is fully working again, both interactively and from `run_forum.ps1`, on the fl...
- **2026-06-22** (Claude): Diagnose why interactive `gemini`/`agy` were failing with API/usage... -> Root cause was a Google regression in agy v1.0.9/1.0.10 (OAuth token exchange fails wit...
- **2026-06-22b** (Claude): agy had silently auto-updated back to the broken v1.0.10 (eligibili... -> agy is pinned to v1.0.8 two ways (env-var kill-switch + ACL deny backstop) so it can no...
- **2026-06-25** (Gemini 3.5 Flash (Medium)): Fix the "src refspec master does not match any" error that occurs d... -> Fixed the push error for `Pub_FlowPaperSP2_TRD` (which is tracked on `main`), updated `...
- **2026-06-25 (second session)** (Gemini 3.5 Flash (Medium)): Address NoteTaker watcher failures on the 20-minute test recording,... -> Handled the 18 MB test recording (transcript, Markdown, and LaTeX summaries written, PD...
- **2026-06-25 (third session)** (Claude): Three infrastructure tasks: (1) stop NoteTaker's free-tier Supabase... -> All three done, validated, committed and pushed. NoteTaker keep-alive is live (watcher ...

---

## Session 2026-06-30
**Agent:** Claude Opus 4.8
**Goal:** User asked whether CLI LLMs integrate with a symbolic math engine (they don't) and how hard it would be to add one (Z3 mentioned) for proof/math verification. Scope it, then build it.
**Files touched:**
- `~/.claude/skills/verify-math/SKILL.md` (new) -- `/verify-math` skill: reads a `.tex`, extracts every labelled equation + numeric claim, translates each to SymPy, runs it via base-env Python, and writes `math_check_report.md` (PASS/FAIL/NOT-CHECKABLE per `\label{}`) + a re-runnable `verify.py` to `{project}\_math_checks\<timestamp>\`. Background Claude agent by default; `--inline` for small files. Checks algebra/series/solve-inversions/distributional-moments/numeric; flags limit-theorem reasoning (CLT/SLLN/Slutsky/Jensen) as out of scope rather than passing it. No gemini/codex backend (checking is execution, not generation). Translation shown per row so formalization errors stay visible.
- `~/.claude/projects/.../memory/reference_sympy_installed.md` (new) -- SymPy 1.14.0 installed in miniconda base env (NOT on PATH, NOT in pyopt); use over in-head arithmetic.
- `~/.claude/projects/.../memory/project_verify_math_skill.md` (new) -- skill record + next idea (forum verification pre-pass).
- `~/.claude/projects/.../memory/MEMORY.md` -- indexed the two new memories.
- miniconda base env -- installed `sympy` 1.14.0 via pip.
**Outcome:** Established SymPy (not Z3) is the right fit for the actual need; Z3 considered but not installed. Live-validated SymPy against `Pub_OptimismBias_PartA\Overleaf_source\Math_Verification.tex` -- Eq.6 aggregation, Eq.12 Mercator series, lognormal moments, calibration inversion, and the Flyvbjerg(2002) Rail table row all passed with zero discrepancies. Built and registered `/verify-math`.
**Next steps:** Optional end-to-end run of `/verify-math --project Pub_OptimismBias_PartA` over the whole file (offered, not yet run). Future: forum (helpi 25) verification pre-pass reusing the translate-and-check logic to inject a "Verified facts" block while keeping forum agents read-only.
**Git ref:** f4c87c7 (root repo; no code/ repo)

---

## Session 2026-06-30 (second session)
**Agent:** Claude Opus 4.8
**Goal:** Document the new `/verify-math` (SymPy) skill in the infrastructure docs with an architecture write-up of the LLM -> SymPy-program -> execute -> interpret pipeline; flag SymPy as a required install; then (follow-up) default the skill to Sonnet 4.6 to save tokens, and push everything to GitHub.
**Files touched:**
- `infrastructure.html` -- added section A3 (`/verify-math`): the four-stage pipeline (read & classify / translate / execute / interpret) rendered as a flow diagram, the six classification buckets with their SymPy mechanism, why the SymPy translation is shown per check, and what is deliberately NOT-CHECKABLE; added a TOC entry; flagged SymPy as a required install in the Prerequisites and desk-reference software tables; added the `--model sonnet|opus` flag row + a "Why Sonnet is the default" note.
- `~/.claude/skills/verify-math/SKILL.md` -- background agent now launches with `model: sonnet` by default; added `--model sonnet|opus` flag (opus for heavy-theory papers); `--inline` keeps the session model; documented the reasoning (model only translates/reports, SymPy judges, translations are printed so mis-translations surface as FAILs).
- `infrastructure_full.pdf` -- regenerated (tracked artifact). First regen was a stale Edge cache render; re-rendered with an isolated `--user-data-dir` and verified the new content is present.
- `infrastructure_summary.html`, `infrastructure_full.html`, `infrastructure_summary.pdf` -- regenerated locally (gitignored).
**Outcome:** `/verify-math` is fully documented with an architecture report; SymPy flagged as an install for full functionality; the skill now defaults to Sonnet 4.6 with an opus override. All committed and pushed to `ai-infrastructure` (master, through a01b57a).
**Next steps:** Optional -- patch `scripts/generate_docs.ps1` to always pass a throwaway `--user-data-dir` to Edge so a running browser can't produce a stale-but-fresh-timestamped PDF, and log it in `known_issues.md` (offered; user did not request).
**Git ref:** 748cb37

---

## Session 2026-06-30 (third session)
**Agent:** Claude Opus 4.8
**Goal:** Fix the stale-PDF bug in `generate_docs.ps1` (helpi 16) surfaced last session, and log it in `known_issues.md`.
**Files touched:**
- `scripts/generate_docs.ps1` -- `Make-Pdf` now launches Edge with a throwaway `--user-data-dir` (temp profile, removed after) so a running browser can't intercept the headless `--print-to-pdf` call and serve a stale cached render; also deletes any prior PDF before rendering (a failed render can't masquerade as fresh) and polls up to 30s for the output instead of a fixed 4s sleep. ASCII-clean additions.
- `known_issues.md` -- added issue #41 (status `fixed (2026-06-30)`): symptom (fresh timestamp, stale content), root cause (running Edge intercepting the headless call), and the fix.
- `infrastructure_full.pdf` -- regenerated as the validation run.
**Outcome:** Fix validated with Edge open (the exact failure condition) -- the output PDF now contains the new content instead of a stale render. Committed and pushed to `ai-infrastructure` (b2298ad).
**Next steps:** none open.
**Git ref:** b2298ad

---

## Session 2026-07-02
**Agent:** Claude Opus 4.8
**Goal:** Design (not yet build) a general code-robustness system for Jeppe's research code, baked into the AI_auto infrastructure. Started with an ad-hoc check: confirmed the Overleaf git server (git.overleaf.com) is down (DNS resolves, TCP 443 refused) -- an outage, not a local problem; GitHub remote works fine.
**Files touched:**
- `~/.claude/projects/.../memory/project_robustness_system.md` (new) -- full design record: optimization-oriented oracle taxonomy (feasibility+objective recompute, duality/relaxation certificates, exact-vs-heuristic differential test, planted/seeded instances, small-exhaustive, benchmark libs + reference impls, monotonicity); the `mip_hybrid` 6x-duplication correctness hazard found in the codebase; agreed `jr_optlib` shared-library architecture reconciled with per-paper reproducibility via version-pin + submission-freeze; three-registry index (vetted fns / known-answer instances / reference impls); OR oracle bank; forward-first-then-migrate sequencing.
- `~/.claude/projects/.../memory/MEMORY.md` -- indexed the new memory.
**Outcome:** Design phase complete and agreed. No infrastructure code written yet -- this was a scoping/architecture conversation. Explored the paper codebases (Pub_MIPEntropy_MPC, Pub_PMIP_AOR, and the SAA/VSP family) to ground the design in what Jeppe actually runs (set-cover + transport/assignment; Gurobi/OR-Tools/CBC + IPF/Sinkhorn/rounding/MH). Confirmed his own code already contains the oracles it needs (exact solver beside heuristics; BestBound/gap already computed; seeded instance generators; a live public-benchmark folder).
**Next steps:** Build session (fresh chat). (1) Decide where `jr_optlib` lives (own project under JR\, init via helpi 27) + index schema; (2) pilot-extract `ipf_2d` as the first vetted function with a scipy/POT + marginal-invariant oracle; (3) stand up the oracle bank with rail582 wired to one check to prove the harness end-to-end. Later: migrate papers one at a time using library-vs-old-copy comparison as the verification. Open: delivery form (/verify-model skill vs helpi command vs both).
**Git ref:** 701c36a
