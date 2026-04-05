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
