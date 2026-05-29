# Global Claude Code instructions

## Platform facts — this machine (read before any tool call)

**Software — use full paths where marked:**
- R 4.5.2 — NOT in PATH: `C:\Users\rich\AppData\Local\Programs\R\R-4.5.2\bin\R.exe`
- Python 3.13.9 (miniconda) — NOT in PATH: `C:\Users\rich\AppData\Local\miniconda3\python.exe` — conda envs: `base`, `pyopt`
- `python3` → Windows Store stub → exit 49. Never use it.
- LaTeX (MiKTeX), git, gh, Node.js v24 — all in PATH; non-interactive `latexmk` may be blocked until MiKTeX first-run setup is completed
- Stata and Julia — not installed

**Tool rules:**
- Use the **PowerShell tool** (not Bash) for any non-trivial PS command — quoting breaks in Bash
- After writing/editing any `.ps1` file, check for curly quotes and fix using the PowerShell tool
- Paths contain spaces (`OneDrive - Danmarks Tekniske Universitet`) — always double-quote; prefer PowerShell tool
- Never use `pwsh -EncodedCommand` inline — write a `.ps1` file and call with `-File`
- `helpi` may complete successfully but fail to update `AI_auto\_state\last_project.txt` from Codex sandbox; treat that state-write warning as non-fatal if the requested helper action reports success.
- **Never put em-dashes or other non-ASCII in `.ps1` string literals.** `helpi.cmd` historically used `powershell` (PS5) which reads UTF-8 files as Windows-1252 — `0x94` (em-dash byte 3) is `"` in that encoding and silently closes strings. Use plain ASCII dashes in PS1 files.

Full reference: `AI_auto\known_issues.md`

---

## Communication style

- Write in plain, direct US English. Avoid jargon, hedging, and filler phrases.
- Don't over-validate or flatter. Be honest and direct, but stay constructive.
- Be ambitious. The research context is competitive — aim high, push hard, and flag opportunities to do better work, not just adequate work.

## Manuscript writing conventions

These apply to all research paper editing and drafting:

1. **Equation references** — always `Eq. (x)`, never "equation x" or "(x)" alone.
2. **Citations** — Harvard style: `Rich (2025)` for narrative, `(Rich, 2025)` for parenthetical. Never footnote-style or numbered.
3. **Paragraph headers** — use `\textit{}` (italic), never `\textbf{}` (bold).
4. **Intuition paragraphs** — every proof of a theorem or proposition is immediately followed by a plain-language paragraph explaining what the result buys us and what it means intuitively. No exceptions.

## Research writing style

When editing or drafting any research text — manuscript paragraphs, intuition sections, introductions, abstracts, referee responses — write in the style of the reference papers in:
`C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\literature\Reference_Papers\`

The full style guide is in `STYLE_GUIDE.md` in that folder. Apply these principles without being asked:

**Do:**
- Economy: cut every word that does not add information or logical force
- Concrete before abstract: ground claims in a specific example before generalizing
- Active voice, first person plural: "We show," "We define," not "It is shown that"
- Transitions that carry logical force: "This implies," "It follows that," not "Furthermore," "Moreover"
- One logical load per sentence — complexity in the logic, not in syntactic nesting
- Consistent terminology: once a term is defined, use it; no synonym rotation

**Cut immediately:**
- Filler openers: "It is worth noting that," "It is important to note that," "Needless to say"
- Hedging: "may potentially," "could possibly," "one might argue," "somewhat"
- Meta-commentary: "In this section we show that," "We now turn to"
- AI-isms: "delve into," "showcase," "leverage," "robust," "nuanced," "paradigm," "facilitate"
- Inflation: "highly significant," "very important," "extremely relevant"
- Wordy constructions: "in order to" → "to"; "due to the fact that" → "because"; "utilize" → "use"
- Filler transitions: "Furthermore," "Additionally," "Moreover" — use logical connectors or none

The target register: confident, precise, unpretentious. Akerlof opens with "This paper relates quality and uncertainty." Einstein opens by naming the asymmetry that motivated the paper. Kahneman & Tversky state their adversarial claim on line one. Write at that level.

## Research project detection

If the user's message contains a Windows path pointing to a folder whose name starts with `Pub_`, `Pro_`, or `PhD_` — and no other instruction is given — treat it as equivalent to running `/work <path>`. Load the project context automatically.

## Project root convention

All research projects live under:
`C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\`

A project name always starts with `Pub_`, `Pro_`, or `PhD_`.

## Per-project CLAUDE.md auto-fill

Every project has a `.claude/CLAUDE.md`. If that file still contains placeholder text (e.g. `[Name, role]`, `[add as they emerge]`, empty `## What this paper is about` section), treat it as unfilled. At session start, before doing anything else:
1. Read the main manuscript in `Overleaf_source/` (largest or most recently modified `.tex` file if no obvious `main.tex`)
2. Check `_ai_log.md` if it exists
3. Fill in all sections of `.claude/CLAUDE.md` with real information — paper description, co-authors, venue, key files, any constraints visible in the manuscript
4. Inform the user: "Filled in `.claude/CLAUDE.md` from the manuscript — please check and correct anything wrong."

Do this silently as part of session startup, not as a separate task requiring user confirmation.

## Session logging

- Always read `_ai_log.md` at the start of a project session.
- Always write (or complete) the session block in `_ai_log.md` at the end of a session, or when the user runs `/close`.
- Never write a session-start entry before the user has confirmed the goal for the session.

## Session length management

Long chats are expensive: every response reprocesses the full history. The handover system makes restarting cheap. Actively manage session length.

**When to propose a close:**
Suggest closing and restarting when ALL of these are true:
1. The conversation has had roughly 20 or more exchanges.
2. A natural break has just occurred — a task is finished, a decision is made, or the topic is shifting.
3. There is no urgent half-finished action in progress.

**How to propose it:**
Say it once, plainly — do not repeat it or nag. Example:
> ⚠ This session is getting long. Good moment to close and restart fresh — the handover will carry everything forward. Run `/close`, then `helpi 7` to regenerate the handover, then open a new chat and `/work` the project.

**On restart:**
If the user opens a new session after a recent close, read `_ai_log.md` and confirm you have the context before asking for a new goal.

## Infrastructure scripts

All automation scripts live in:
`C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\`

Use `helpi N [Project] [-Force]` to run them. Full reference: `AI_auto\infrastructure.html`.

| N  | Command                         | Project? | When to use |
|----|---------------------------------|----------|-------------|
| 1  | Create new project              | Yes      | Once per paper |
| 2  | Pull ALL projects from Overleaf | --       | Start of day |
| 3  | Pull ONE project from Overleaf  | Yes      | Before opening a project |
| 4  | Push local edits to Overleaf    | Yes      | After editing manuscript locally |
| 5  | Compile + open VS Code + PDF    | Yes      | Start of working session |
| 6  | Compile LaTeX + open PDF only   | Yes      | Quick recompile |
| 7  | Log + handover + open browser   | Yes      | End of session / checkpoint |
| 8  | Snapshot Overleaf (git tag)     | Yes      | Before major revision or submission |
| 9  | Rollback last N code commits    | Yes      | Undo bad code changes (PERMANENT) |
| 10 | Build submission package        | Yes      | Submitting a paper |
| 11 | Reviewer scaffold (.txt->LaTeX) | Yes      | After receiving reviewer comments |
| 12 | Reviewer draft loop             | Yes      | After annotating scaffold in Overleaf |
| 13 | Project status dashboard        | --       | Anytime |
| 14 | Open project network graph      | --       | Anytime |
| 15 | Open infrastructure guide       | --       | Anytime |
| 16 | Generate docs (HTML/PDF)        | --       | After editing infrastructure.html |
| 17 | Claude Code cheatsheet          | --       | Anytime |
| 18 | Toggle Claude model-check       | --       | Anytime |
| 19 | Generate Beamer slides          | Yes      | Before a presentation |
| 20 | Restore on replacement machine  | --       | Machine setup |
| 21 | First-time setup for new user   | --       | Machine setup |
| 22 | Compress AI log                 | Yes      | Auto-run by /close; manual on demand |
| 23 | Push code/ to GitHub            | Yes      | After code changes |
| 24 | Technical one-pager from paper  | Yes      | Anytime |

## AI infrastructure project detection

If the user's message contains a path with `AI_auto` as a component — and no other instruction is given — treat it as opening a session on the infrastructure project itself. Read `infrastructure.html` in that folder for full context before responding. Follow the same session discipline as research projects: confirm the goal before starting, log at the end.

At the start of any AI_auto session, run `/catch-up` before doing other work to apply any open fixes logged in `known_issues.md`.

