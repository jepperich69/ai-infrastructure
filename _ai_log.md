# AI Session Log — AI Infrastructure Project

---

## Session 2026-04-05
**Agent:** Claude Sonnet 4.6
**Goal:** Set up lightweight versioning for the AI infrastructure; implement a stable/develop branch model; act on GPT's code review findings.
**Files touched:**
- `CHANGELOG.md` — created; documents v0.1 and v0.2 releases with a running unreleased section
- `VERSION` — created; current value v0.2
- `RELEASING.md` — created; plain-language instructions for making a new release
- `infrastructure.html` — version field added to subtitle; new versioning section added at the bottom
- `.gitignore` — created; excludes logs/ and overleaf_projects.csv
- `snapshot.ps1` — removed silent auto-commit of dirty state before tagging; now aborts with a clear file list and commit/discard instructions
- `C:\Users\rich\.claude\CLAUDE.md` — added session length management section: Claude proposes ⚠ close+restart at ~20 exchanges on a natural break
**Outcome:** Infrastructure is now git-versioned (GitHub: jepperich69/ai-infrastructure), released at v0.2, with a working stable/develop branch model and the main operational footgun in snapshot.ps1 fixed.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch so it degrades gracefully in non-interactive shells (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` sourced by all scripts (v0.3 candidate)
**Git ref:** ee25caf

---

## Session 2026-04-05 (evening)
**Agent:** Claude Sonnet 4.6
**Goal:** Consistency-cleanup pass on v0.2 based on GPT code review recommendations.
**Files touched:**
- `RELEASING.md` — updated "Current state" to v0.2, rewired "Working toward" to v0.3, made VERSION the explicit single source of truth in release steps
- `infrastructure.html` — updated version string to v0.2 (with VERSION SOT note), fixed snapshot diagram label from "copy main.tex" to "git tag full Overleaf_source/", fixed snapshot workflow description from "saves main.tex as frozen copy" to "git-tags full Overleaf_source/ state"
- `snapshot.ps1` — tightened abort guidance: replaced single destructive `checkout -- .` suggestion with three labelled options (commit / stash / discard), stash marked reversible, discard marked PERMANENT
**Outcome:** v0.2 is now consistent across all docs and scripts; snapshot safety posture improved.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** 3a9143d

---

## Session 2026-04-07
**Agent:** Claude Sonnet 4.6
**Goal:** Auto-generate separate PDF and HTML exports for the 1-2 pager and the full infrastructure guide.
**Files touched:**
- `generate_docs.ps1` — created; reads infrastructure.html, splices two CSS variants into the @media print block, writes infrastructure_summary.html and infrastructure_full.html, then calls Edge headless to produce matching PDFs
- `helpi.ps1` — added command 16 "Generate docs (summary + full HTML/PDF)" wired to generate_docs.ps1; preview and bounds-check updated automatically via `$commands.Count`
- `.gitignore` — added the four generated output files (infrastructure_summary/full .html/.pdf) as gitignored artifacts
**Outcome:** Running `helpi 16` (or `.\generate_docs.ps1`) now produces four files: a summary HTML/PDF showing only the 1-2 pager and a full HTML/PDF showing the complete guide.
**Next steps:**
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** 5c80af8

---

## Session 2026-04-08
**Agent:** Claude Sonnet 4.6
**Goal:** Design and implement a proxy-sandbox for per-project Claude file isolation; document DTU AI data policy compliance; set up shared Sensitive_Data folder.
**Files touched:**
- `new_project.ps1` — added `.claude/settings.json` scaffold step: denies reads from AI_auto, AppData, and ~/.claude on every new project
- `infrastructure.html` — added §7b (proxy-sandbox design, two-level deny rules, DTU policy compliance table, Sensitive_Data folder convention); updated project folder structure listing to include `.claude/settings.json`
- `infrastructure_summary.html` / `infrastructure_full.html` / `_summary.pdf` / `_full.pdf` — regenerated via `generate_docs.ps1`
- `C:/Users/rich/.claude/settings.json` — added global deny rule for `JR/Sensitive_Data/**`
- `JR/Sensitive_Data/code/` — folder created as shared human-only zone for sensitive source data and analysis scripts
**Outcome:** Claude Code is now structurally confined to project folders via a per-project deny list and a global block on the shared Sensitive_Data folder; DTU AI data policy compliance is documented in §7b as a structural property of the setup, not a matter of discipline.
**Next steps:**
- Write `Sensitive_Data/code/generate_testdata.py` — synthetic test data generator supporting CSV, Excel, and Access (.accdb) input; CSV output; profile-based sampling per column
- `helpi.ps1`: wrap PSConsoleReadLine call in try/catch for non-interactive shell degradation (v0.3 candidate)
- Extract hardcoded `$aiRoot` / `$pubRoot` paths to a shared `config.ps1` (v0.3 candidate)
**Git ref:** a56d604
