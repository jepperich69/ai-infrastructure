# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-05-30** (Claude): Add `/style-edit` skill for background LaTeX prose editing, then re... -> `/style-edit` skill added for autonomous background prose-style editing of LaTeX manusc...
- **2026-05-30b** (Claude): Push v1.0 to GitHub, remove redundant root helpi.ps1 shim, and upda... -> v1.0 fully pushed to GitHub; documentation updated and regenerated to match the scripts...
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

---

## Session 2026-06-25 (second session)
**Agent:** Gemini 3.5 Flash (Medium)
**Goal:** Address NoteTaker watcher failures on the 20-minute test recording, prevent OneDrive from downloading all project folders during active project syncs, and generate Markdown, LaTeX, and compiled PDF summary outputs.
**Files touched:**
- `NoteTaker/code/notetaker_watcher.ps1` -- Integrated the Gemini File API (raw upload, generateContent with file_uri, and DELETE cleanup) for audio files > 4MB to prevent 503 errors and size limit issues; optimized `Sync-Projects` to sort project folders using parent folder `LastWriteTimeUtc` directly instead of checking `_ai_log.md` inside every folder (stops OneDrive from downloading inactive projects); and cached downloaded assets locally to avoid redownloads during watcher retries.
**Outcome:** Handled the 18 MB test recording (transcript, Markdown, and LaTeX summaries written, PDF compiled successfully, and GitHub spool asset deleted). Replaced the old watcher processes with the updated script under the supervisor loop in hidden mode.
**Next steps:** none.
**Git ref:**

---

## Session 2026-06-25 (third session)
**Agent:** Claude Opus 4.8
**Goal:** Three infrastructure tasks: (1) stop NoteTaker's free-tier Supabase project from auto-pausing after 7 days idle, (2) fix the `helpi 4` hang when Overleaf is ahead during headless agent runs, (3) document install prerequisites so the infrastructure can be handed to a colleague.
**Files touched:**
- `NoteTaker/code/notetaker_watcher.ps1` -- added `Send-SupabaseKeepAlive` (a CORS OPTIONS ping the Edge Function answers 200 before any auth, no secret/audio) fired on watcher startup and every 12h, so the project never crosses Supabase's 7-day inactivity pause threshold.
- `NoteTaker/RECOVERY_GUIDE.md` -- documented the keep-alive as section 2b (automatic guard, manual "any recording counts" fallback, long-holiday risk, REST-call backup).
- `scripts/config.ps1` -- set `GIT_TERMINAL_PROMPT=0`, `GCM_INTERACTIVE=Never`, `GIT_PAGER=cat` (dot-sourced by every infra script) so headless git ops fail fast instead of hanging on a credential prompt; this was the root cause of `helpi 4` hanging when Overleaf was ahead.
- `INSTALL.md` (new) -- single onboarding doc: accounts/licenses table (paid ones flagged), software + npm CLIs, and an agent-executable runbook with HUMAN STEP markers at the account/payment/OAuth/key-generation points. Clarifies AI_auto core needs no API-key env vars; GEMINI_API_KEY/GITHUB_WRITE_PAT are NoteTaker-only.
- `README.md` -- added an "Installing" pointer to INSTALL.md; Requirements now lists Node.js and flags Overleaf git access as paid.
**Outcome:** All three done, validated, committed and pushed. NoteTaker keep-alive is live (watcher restarted under supervisor; OPTIONS ping returns 200, inactivity clock reset today). config.ps1 guard validated (parses clean, env vars apply on source). AI_auto pushed to `ai-infrastructure` (b400112); NoteTaker keep-alive pushed to `notetaker-inbox` (43340dc, rebased over the watcher's auto-sync commits).
**Next steps:** none open. Optional: record the `helpi 4` headless-hang fix in `known_issues.md` for `/catch-up` (offered; user did not request). Real-world test of the fix happens next time `helpi 4` runs from agy with Overleaf ahead.
**Git ref:** b400112

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
