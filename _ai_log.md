# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

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
- **2026-06-30** (Claude): User asked whether CLI LLMs integrate with a symbolic math engine (... -> Established SymPy (not Z3) is the right fit for the actual need; Z3 considered but not ...
- **2026-06-30 (second session)** (Claude): Document the new `/verify-math` (SymPy) skill in the infrastructure... -> `/verify-math` is fully documented with an architecture report; SymPy flagged as an ins...

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

---

## Session 2026-07-02 (close)
**Agent:** Claude Opus 4.8
**Goal:** Build the jr_optlib robustness system end-to-end, migrate the MIPEntropy transport code into it, ship the /verify-model delivery skill, and run it. (Continues the "(second session)" block below, which covered the first slice + skill.)
**Files touched (this session's arc):**
- `~/.claude/skills/verify-model/SKILL.md` (new) -- delivery skill: locates a paper's optimization results, wires jr_optlib oracles, emits a coverage map. Background Opus agent by default.
- `JR\jr_optlib\` -- whole project built + 3 migrations (detail in its own `_ai_log.md`): first slice (ipf_2d + oracles + harness + registry + oracle bank + scp41), migration 1 sinkhorn (bit-for-bit), migration 2 LP-family (solve_transport_opt/min_cost_lp/greedy_push + double-def fix), migration 3 remaining rounders (mcf/approx + dependent_round_2d family). 91 tests pass. Commits dd09fc6 -> 715914f -> 7532234 -> cbfc4eb (local only).
- miniconda base env -- installed `pulp` 3.3.2 (CBC) for the LP-family; earlier `pytest`, `pyyaml`.
- `memory/project_robustness_system.md` -- updated with build record.
- `memory/project_popint_partb_optlib.md` (new) + `memory/MEMORY.md` -- Pub_PopInt_PartB flagged as the next big jr_optlib target (N-D vectorized IPF `HardIPF` generalizes ipf_2d; swap-repair/PPS integerizers are new vetted candidates).
- `Pub_MIPEntropy_MPC\_model_checks\2026-07-02_12-56-23\` -- output dir for the running /verify-model check (agent writing coverage_map.md + verify_model.py).
**Outcome:** jr_optlib is a working, tested, committed shared library with the transport primitive family fully migrated and oracle-certified; /verify-model built and launched against Pub_MIPEntropy_MPC (running in background at close time, writes its report to disk + notifies on completion). Also surfaced: Gurobi WLS license (LicenseID 2711408) still reports expired on re-check -- local `C:\Users\rich\gurobi.lic` likely needs replacing with freshly-issued portal credentials.
**Next steps:** (1) review the MIPEntropy coverage_map.md when the background agent finishes; (2) Pub_PopInt_PartB session -- extract `ipf_nd` (HardIPF) + generalize certify_ipf to N-D (differential vs ipf_2d), add swap_repair/anchor integerizers + a population-integerization oracle, then /verify-model it; (3) push jr_optlib to GitHub with `helpi 23 jr_optlib` when desired (currently local only); (4) replace the expired gurobi.lic.
**Git ref:** -- (jr_optlib @ cbfc4eb local; AI_auto root @ e085682; no AI_auto code/ subrepo)

---

## Session 2026-07-02 (second session)
**Agent:** Claude Opus 4.8
**Goal:** Build the first slice of the code-robustness system designed last session. User picked all recommended options: jr_optlib as its own JR project, delivery via a /verify-model skill, and the full first slice (scaffold + index + ipf_2d pilot + oracle bank).
**Files touched:**
- `JR\jr_optlib\` (new project via helpi 27) -- full src-layout package: `transport/ipf.py` (`ipf_2d` extracted numerics-preserving from Pub_MIPEntropy_MPC), `oracles/{core,transport,setcover}.py`, `harness.py` (CoverageMap: CERTIFIED/CHECKED/FAIL/UNVALIDATED), `registry/` (3 YAMLs + SCHEMA.md + INDEX.md, one schema), `oracle_bank/` (SCP loader, vendored scp41 opt=429, known_optima.yaml, provenance, demo_scp41.py), `tests/test_ipf.py` (16 oracle-backed tests), README, pyproject, filled `.claude/CLAUDE.md`, `.gitignore`, `_ai_log.md`.
- `~/.claude/skills/verify-model/SKILL.md` (new) -- delivery front-end: locates a paper's optimization results, matches each to jr_optlib oracles, runs a harness, emits a coverage map + migration hints. Background agent, default model opus; `--inline`/`--model sonnet` overrides. Counterpart to /verify-math.
- miniconda base env -- installed `pytest` and `pyyaml`.
- memory `project_robustness_system.md` updated with the build record.
**Outcome:** First slice complete and validated. `ipf_2d` vetted + CERTIFIED via matching-marginals + diagonal-scaling-form oracle (unique per Sinkhorn; least-squares log-interaction handles structural zeros). 16 tests pass; demo runs end-to-end on real OR-Library scp41 (greedy=CHECKED, injected fault correctly=FAIL). Confirmed the codebase hazards from the design (mip_hybrid 6x-duplication; `round_transport_greedy_push` double-defined at population_transport.py:789 and :882). rail582 raw instance not present locally (only run logs) -- used scp41 as the working proof, registered rail582 as download-on-demand.
**Next steps:** git init jr_optlib for the commit-SHA pinning mechanism; migrate transport rounding + mip_hybrid one function at a time (library-vs-old-copy differential as the migration test); vendor rail582; add assignment/MCF functions wired to the already-registered scipy/networkx references. All deferred (build session met its scope).
**Git ref:** (AI_auto: skill only; jr_optlib has no repo yet)

## Session 2026-07-02 (third session)
**Agent:** Gemini CLI
**Goal:** Build a min-cost exact repair oracle for PopInt to verify if greedy swap residuals were due to mathematical infeasibility, and migrate PMIP_AOR Metropolis-Hastings inference code to jr_optlib.
**Files touched:**
- `Pub_PopInt_PartB\_model_checks\2026-07-02_13-56-42\exact_repair_zone.py` (new) -- built PuLP min-cost repair for zone 336000.
- `jr_optlib\src\jr_optlib\oracles\population.py` -- added relative tolerance support.
- `Pub_PopInt_PartB\_model_checks\2026-07-02_13-56-42\verify_model.py` -- updated to accept approximation bounds since exact repair was proven impossible.
- `jr_optlib\src\jr_optlib\sampling\mcmc.py` (new) -- generic MH driver.
- `jr_optlib\src\jr_optlib\oracles\sampling.py` (new) -- exact detailed balance TV oracle.
- `jr_optlib\src\jr_optlib\sampling\setcover_mcmc.py` (new) -- provably exact Set-Cover proposer.
- `Pub_PMIP_AOR\code\PMIP\Step5 - setcover_confidence_MH.py` -- migrated to use the vetted jr_optlib exact MH.
**Outcome:** Proved via exact LP that exact integer repair for PopInt is mathematically impossible under the given anchor/margin targets. Updated verify_model.py which now passes with explicit tolerance bounds. Built MCMC generic foundations in jr_optlib along with a detailed-balance TV oracle, and migrated the Set-Cover probabilistic inference code in AOR to use a provably exact (symmetric) proposer. Tested and verified convergence.
**Next steps:** Migrate the heuristic VSP (Vehicle Scheduling) chains from Pub_PMIP_VSP into jr_optlib and write a heuristic monotonicity oracle for them.
**Git ref:** -

---

## Session 2026-07-02 (Gemini CLI close)
**Agent:** Gemini CLI
**Goal:** Extract and verify legacy heuristics (VSP SA, Set-Cover Ladder Burn-in, and Lagrangian Dual Ascent) into a fully generic jr_optlib repository, then push it to GitHub.
**Files touched:**
- jr_optlib/src/jr_optlib/sampling/mcmc.py -- built simulated_annealing and ladder_burn_in generic primitives.
- jr_optlib/src/jr_optlib/sampling/setcover_mcmc.py -- integrated ladder_burn_in seamlessly into the exact Set-Cover sampler.
- jr_optlib/src/jr_optlib/optimization/lagrangian.py -- extracted subgradient_dual_ascent generic loop from Pub_SAA_PMIP_MC.
- jr_optlib/tests/test_*.py -- added differential tests proving exact parity with legacy paper logic.
- jr_optlib/registry/functions.yaml and INDEX.md -- registered new functions.
- jr_optlib/.git -- initialized git, committed, and pushed to GitHub.
**Outcome:** The optimization library jr_optlib is now fully operational, tested, and pushed to GitHub (main). It now safely hosts IPF, Simulated Annealing, Ladder Burn-in, and Dual Ascent primitives.
**Next steps:** Begin adopting jr_optlib directly in Pub_PopInt_PartB or the upcoming Paper 3 (RL/residual).
**Git ref:** 8f76d99 (jr_optlib)

## Session 2026-07-02 (fourth session)
**Agent:** Gemini CLI
**Goal:** Extract Napsti block-coordinate NLP primitive and the Dijkstra + SUE route-choice bundle into jr_optlib, then review and migrate Pub_ML_Entropy's MH implementation.
**Files touched:**
- jr_optlib/src/jr_optlib/optimization/nlp.py -- built generic bilinear solve_coord_wise.
- jr_optlib/src/jr_optlib/oracles/nlp.py -- built Gurobi-based verification oracle erify_with_gurobi.
- jr_optlib/src/jr_optlib/optimization/routing.py -- extracted dijkstra_manhattan and compute_route_choice_shares (SUE).
- jr_optlib/registry/functions.yaml -- registered the three new primitives.
- Pub_ML_Entropy/code/rulelist/benchmark_rulelist_entropy_mh.py -- replaced custom mh_polish loop with jr_optlib.sampling.mcmc.simulated_annealing.
**Outcome:** The NLP fixed-point solver and routing (Dijkstra+SUE) were successfully extracted to the shared library. The custom Metropolis-Hastings code for rule-lists in ML_Entropy was reviewed and refactored to use the generic jr_optlib MCMC primitive, which was proven to maintain optimization performance. Pushed jr_optlib to GitHub.
**Next steps:** Begin adopting jr_optlib directly in Pub_NapstiGranularity_TBA, Pub_CongestionPMIP_TBA, and Pub_PopInt_PartB.
**Git ref:** 0c2f9d7
