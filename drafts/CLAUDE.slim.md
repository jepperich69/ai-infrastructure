# Global instructions

## This machine
- R 4.5.2, not on PATH: `C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe`
- Python 3.13.9 (miniconda), not on PATH: `C:\Users\rich\AppData\Local\miniconda3\python.exe`. Envs: `base`, `pyopt`. `python3` is a Windows Store stub (exit 49); never use it.
- Venvs go in `C:\Users\rich\venvs\`, never inside OneDrive. Point `.vscode/settings.json` at the interpreter. PyTorch conflicts with `pyopt`'s OpenMP; use a project venv, not `KMP_DUPLICATE_LIB_OK` (known_issues #45, #51).
- Biogeme 3.3.4: `C:\Users\rich\venvs\biogeme313\Scripts\python.exe`. Use 3.3.x, not 3.2.x (#51).
- QGIS 3.44.12 has its own Python; add it per project with `helpi 28`. Never set `QGIS_PREFIX_PATH` by hand (#50).
- `agy` is pinned to v1.0.8. Never update it or use it in automation; automation uses `gemini --model gemini-2.5-flash` (#37).
- LaTeX (MiKTeX), git, gh, Node 24 are on PATH. Stata and Julia are not installed.
- Profiling: read `AI_auto\PROFILING.md` first. Use scalene, not cProfile.

## Shell rules
- Paths contain spaces (`OneDrive - Danmarks Tekniske Universitet`); always quote them.
- Use the PowerShell tool for non-trivial PS. Never `pwsh -EncodedCommand`; write a `.ps1` and run it with `-File`.
- `.ps1` files: ASCII only in string literals (PS5 misreads UTF-8 em-dashes), and check for curly quotes after every edit.
- Infrastructure scripts are in `AI_auto\scripts\`. Invoke helpi as `helpi` or `AI_auto\helpi.cmd`.
- Overleaf remotes may advertise `master` but accept only `main`; check the tracked branch before pushing.
- Anything else odd: `AI_auto\known_issues.md`.

## How to answer
Plain, direct US English. Lead with the answer, keep prose under ~150 words, report results rather than process, and close with a `Drill down: (a) ... (b) ...` line when there is more to give. Write at full length for deliverables, explicit requests for detail, and anything the user must know before an irreversible action. Be honest rather than flattering, and push for ambitious work.

Math in the terminal: displayed equations are rendered 2D with `C:\Users\rich\.claude\skills\verify-math\scripts\render_math.py` inside a code fence; inline math uses Unicode glyphs. Never render inside `.tex` or anything that gets saved.

## Research writing
Before adding or changing any sentence of research text (manuscripts, abstracts, captions, reviewer responses, cover letters), read `AI_auto\literature\Reference_Papers\STYLE_GUIDE.md` and follow it. That applies to content edits too, not only style passes. The fixed conventions: `Eq. (x)`, Harvard citations, `\textit{}` paragraph headers, and an intuition paragraph after every proof.

## Projects
- A project is any folder under `JR\` that directly contains `_ai_log.md`. Paper projects are `JR\Publikationer\Pub_*|Pro_*|PhD_*`. A path to such a folder with no other instruction means `/work <path>`. A path containing `AI_auto` means an infrastructure session: read `infrastructure.html` and run `/catch-up` first.
- Read `_ai_log.md` at session start. Write the session block only after the user confirms the goal, and complete it at the end or on `/close`.
- If the project's `.claude/CLAUDE.md` still has placeholders, fill it from the manuscript (or the project files) and tell the user to check it.
- New non-paper project: `helpi 27`. Commands: `helpi 4` pushes to Overleaf, `helpi 7` writes the log and handover, `helpi 22` compresses the log. Full table: `AI_auto\infrastructure.html`.
- After ~20 exchanges, at a natural break, suggest `/close` once.

## Sources and code
- A fetched source that ends up backing a claim in the work gets saved to `Literature/Author_Year_ShortTitle.ext` and logged in `Literature/_retrieved_sources.md`. Never edit the user's own reading notes.
- Optimization and sampling primitives: check `JR\jr_optlib` (`INDEX.md`, `registry/`) before writing one. A new primitive ships with an oracle, a test and a registry entry; without an oracle it is `experimental`. Pin papers to a commit SHA. In papers write "checked against independent oracles", never "formally verified".
