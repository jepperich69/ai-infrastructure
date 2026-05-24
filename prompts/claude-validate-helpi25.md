AGENT PROTOCOL: CLAUDE FINAL VALIDATION FOR HELPI 25

[ROLE]
You are Claude performing the last validation stage for the AI_auto `helpi 25`
Convergence Forum command after Codex's audit and patch.

[CONTEXT]
The relevant files are:
- `helpi.ps1`
- `run_forum.ps1`
- `prompts/code-audit.md`
- `prompts/lit-review.md`
- `prompts/math-verify.md`
- `prompts/repro-audit.md`
- `prompts/final-pass.md`
- `prompts/forum_roles/critic_sys.md`
- `prompts/forum_roles/advocate_sys.md`
- `prompts/forum_roles/realist_sys.md`
- `_ai_log.md`

Codex patched three issues:
1. `helpi 25 code-audit` should work as a compact shortcut from inside AI_auto
   or a project folder, mapping `code-audit` to the task/template rather than
   treating it as the project.
2. A forum that reaches `MaxRounds` without convergence should finish with
   `Status: adjourned`, not stale `Status: active`.
3. Default forum runs should not open files or spawn Claude auto-close unless
   explicitly requested with `-OpenFinal` or `-AutoClose`.

[VALIDATION TASKS]
1. Read `known_issues.md` first and respect all platform facts.
2. Inspect `helpi.ps1` and `run_forum.ps1` for PowerShell syntax, argument
   binding, path handling, and side effects.
3. Verify, without running a costly multi-agent forum unless explicitly
   approved by Richard, that these command forms map correctly:
   - `helpi 25 code-audit`
   - `helpi 25 code-audit -Agent codex -Mode SAD`
   - `helpi 25 AI_auto code-audit`
   - `helpi 25 AI_auto code-audit -Agent codex -Mode SAD`
4. Verify that `run_forum.ps1` no longer opens `final.md` or calls Claude
   auto-close by default.
5. Verify that `-OpenFinal` and `-AutoClose` are opt-in and documented in the
   script parameter block.
6. Verify that both edited `.ps1` files are free of curly quotes and UTF-8 BOM.
7. Give a concise verdict:
   - READY if no blocking issue remains.
   - READY WITH NOTES if only documentation or polish remains.
   - NOT READY if a command path can misfire or a default side effect remains.

[OPTIONAL SMOKE TEST]
Only if Richard explicitly approves LLM/tool spend, run a one-round test using
the cheapest practical configuration:

`& "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\helpi.ps1" 25 AI_auto code-audit -Agent codex -Mode SAD -Force`

Stop after the first clear failure. Do not push to Overleaf or GitHub.

[OUTPUT FORMAT]
## Claude Final Validation
- Verdict:
- Checks performed:
- Findings:
- Residual risks:
- Recommended next action:
