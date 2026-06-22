# AI Session Log — AI Infrastructure Project

---

## Compressed sessions

- **2026-05-27b** (Claude): Add automatic backup and restore of `~/.claude/` so the AI infrastr... -> `~/.claude/` is now backed up to `_claude_backup/` (OneDrive + GitHub) on every session...
- **2026-05-29** (Claude): Set up a writing style guide from classic reference papers to gover... -> Writing style guide created and wired into global CLAUDE.md; tested on a research parag...
- **2026-05-29c** (Claude): Fix `/close` to run without permission prompts -> Root cause identified: subagents spawned via `Agent` tool have an independent permissio...
- **2026-05-29d** (Claude): Fix remaining `/close` permission prompts after subagent removal -> Two root causes found and fixed: (1) `**` in the middle of Edit/Write glob patterns doe...
- **2026-05-26b** (Claude): Add `-Stage` parameter to the Convergence Forum to prevent agents f... -> Forum agents now operate in surgical/defect-detection mode when `-Stage revision` or `-...
- **2026-05-29b** (Claude): Extend infrastructure with Haiku-delegated /close, fix permission g... -> /close now delegates mechanical operations to a Haiku subagent; permission patterns ext...
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

---

## Session 2026-06-16
**Agent:** Claude Sonnet 4.6
**Goal:** Fix `run_forum.ps1` failing for projects outside the `Publikationer` folder (e.g. `NoteTaker` in `JR/`).
**Files touched:**
- `scripts/run_forum.ps1` -- replaced hardcoded `$PubRoot` with `. "$PSScriptRoot\config.ps1"` and switched path resolution to `Resolve-ProjectRoot`, matching all other scripts
**Outcome:** Forum (helpi 25) now resolves projects in any subfolder under `JR/`, not only `Publikationer/`.
**Next steps:** none

---

## Session 2026-06-17
**Agent:** Claude Sonnet 4.6
**Goal:** Extend the AI infrastructure so any non-paper folder under `JR\` gets the same session logging, compression, and helpi functionality that `Pub_`/`Pro_`/`PhD_` paper projects already have.
**Files touched:**
- `scripts/config.ps1` -- exposed a shared `$jrRoot` variable (parent of `$pubRoot`) for use by other scripts
- `scripts/helpi.ps1` -- switched `Get-ProjectFromCwd` from a hardcoded name-pattern match to marker-based detection (walks up to the nearest folder containing `_ai_log.md`); added command 27, "Create generic project (non-paper)"
- `scripts/new_generic_project.ps1` -- new script (helpi 27): lightweight init for a non-paper project folder anywhere under `JR\` -- creates `_ai_log.md`, `.claude/CLAUDE.md` (generic template), `.claude/settings.json`, skipping the Overleaf/code/Literature scaffolding `helpi 1` creates for papers
- `scripts/status.ps1` -- dashboard (`helpi 13`) now scans all of `JR\` for `_ai_log.md`, not just `Publikationer\`
- `scripts/network.ps1` -- network graph (`helpi 14`) now includes generic projects (as standalone nodes) alongside Overleaf-registered papers
- `~/.claude/commands/work.md`, `~/.claude/commands/close.md` -- updated project-root resolution to the same marker-based rule; fixed a stale path in `close.md` step G (`generate_handover.ps1` is under `scripts/`, not `AI_auto\` root)
- `~/.claude/CLAUDE.md` -- documented the new generic-project workflow, updated "Research project detection" and "Project root convention", backfilled missing helpi 25-26 rows and added 27 to the command table

Note: the `~/.claude/commands/*.md` and `~/.claude/CLAUDE.md` files live outside this repo (in the user's home `.claude/` folder) and are not part of any AI_auto commit.
**Outcome:** Verified end-to-end with a throwaway test folder (`JR\_test_generic_project_DELETE_ME`, since deleted): `helpi 27` initializes correctly, `Get-ProjectFromCwd` detects it from inside the folder, `helpi 13`/`helpi 22`/`generate_handover.ps1` all work against it unmodified. Testing also surfaced and fixed a path-resolution bug in the new init script (it initially misused `Resolve-ProjectRoot`, which defaults to `Publikationer\` for not-yet-existing folders, misplacing new generic projects). Confirmed two folders the user had already informally set up this way (`CV`, `NoteTaker`) now show up correctly in `helpi 13`/`helpi 14` via the marker-based scan.
**Next steps:** none required; optionally update `infrastructure.html`'s hand-maintained command-reference tables (already stale before this session -- missing rows 25/26) via `helpi 16`; optionally register generic projects in `projects.json` if feeder-link relationships are ever wanted for them in the network graph.
**Git ref:** 9e335d6
**Git ref:** d627315

---

## Session 2026-06-19
**Agent:** Claude Sonnet 4.6
**Goal:** Fix Gemini CLI auth (broken by Google's OAuth deprecation for individuals) so `run_forum.ps1` works again, and evaluate whether the newly-installed Antigravity CLI (`agy.exe`) should replace or join it as a Convergence Forum agent.
**Files touched:**
- `C:\Users\rich\.gemini\settings.json` -- switched `security.auth.selectedType` from `oauth-personal` (now dead for individuals) to `gemini-api-key`, using the existing `GEMINI_API_KEY` env var
- `scripts/run_forum.ps1` -- added `--model gemini-2.5-flash` explicitly to both `gemini` invocations (Invoke-Agent and AutoClose block), since the API key has zero free-tier quota for the CLI's default `gemini-2.5-pro`
- `known_issues.md` -- added issue #36 (Gemini CLI OAuth death + zero-quota default model, fixed) and issue #37 (Antigravity CLI `agy.exe` hangs indefinitely in every non-interactive invocation method tried -- background job, piped Start-Process, cmd.exe file redirection -- works only when typed directly into a real interactive terminal; open, not integrated)
- User-level env var `GEMINI_MODEL` set to `gemini-2.5-flash` as the interactive default (not a tracked file)
**Outcome:** `gemini` is fully working again, both interactively and from `run_forum.ps1`, on the flash model. `agy` was authenticated and confirmed functional interactively, but is not usable headlessly in its current state, so it was not wired into the Forum; this was deliberately logged as an open issue rather than worked around.
**Next steps:** none required. Optional future work: (1) enable billing on the Gemini API key's project to unlock `gemini-2.5-pro` quota if Forum debate quality on flash proves insufficient; (2) revisit `agy` integration if the console-attachment hang is ever resolved (e.g. via `wt.exe`/ConPTY-aware launching).
**Git ref:** 43404c4

---

## Session 2026-06-22
**Agent:** Claude Opus 4.8
**Goal:** Diagnose why interactive `gemini`/`agy` were failing with API/usage-limit errors after the June model changes, restore working interactive Gemini access, and formalize a two-track model convention (interactive vs automation).
**Files touched:**
- `C:\Users\rich\.gemini\settings.json` -- pinned `model.name = gemini-2.5-flash` (belt-and-suspenders alongside the `GEMINI_MODEL` env var; note CLI bug #5373/#2205 can ignore settings.json model on Windows)
- `C:\Users\rich\AppData\Local\agy\bin\agy.exe` -- downgraded from broken v1.0.9/1.0.10 to known-good v1.0.8 (backup at `agy.exe.bak_20260622_085759`)
- `~/.claude/skills/pipeline/SKILL.md` -- pinned the gemini round to `--model gemini-2.5-flash` (was unpinned, could drift onto 3.x and exhaust free quota mid-run) and documented the two-track convention in Notes
- `known_issues.md` -- extended #36 (interactive 3.5-flash quota trap) and #37 (agy v1.0.9/1.0.10 OAuth `token exchange failed` regression, 1.0.8 downgrade procedure, do-not-update warning, two-track convention)
- `~/.claude/CLAUDE.md` -- added global platform fact: pin `agy` to v1.0.8, never update, interactive-only; automation uses classic `gemini --model gemini-2.5-flash`
**Outcome:** Root cause was a Google regression in agy v1.0.9/1.0.10 (OAuth token exchange fails with `read tcp ... connection reset`), NOT a firewall/account/subscription issue (proved endpoint reachable via direct REST 400 + working API key). Downgrading to v1.0.8 restored interactive login (now caches silently as `jeppe.rich@gmail.com`, Google AI Pro, Gemini 3.5 Flash). Two-track split now enforced and documented: interactive = `agy` (3.5 Flash, subscription); automation (Forum + pipeline) = classic `gemini` hard-pinned to 2.5-flash on the free API key.
**Next steps:** none. Watch for agy silently auto-updating back to 1.0.10 (re-swap 1.0.8 if login breaks again). Optionally enable billing on the API key if 3.x is ever wanted inside automation.
**Git ref:**
