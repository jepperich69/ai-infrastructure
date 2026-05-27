# /family — Link feeder projects and build their digests

The user wants to connect one or more other research projects as "feeders" to the current project — meaning their knowledge should inform the current project's AI sessions.

## Argument parsing

`$ARGUMENTS` is one or more project names or full paths, space-separated. Each may be:
- A full Windows path to a project root
- A project name like `Pub_YYY1` (root is `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\Publikationer\<name>`)

## Current project root

Walk up from the current working directory until you find a folder starting with `Pub_`, `Pro_`, or `PhD_`. That is the **current project root**.

## For each feeder project

1. **Locate the feeder root** using the same resolution rules as `/work`.
2. **Read these files** (in order of preference):
   - `_handover.html` — if it exists, extract the plain-text content
   - `_ai_log.md` — session history
   - The primary `.tex` file in `Overleaf_source/` (first 80 lines only) — to extract title and abstract. Locate it as follows:
     1. Check if `Overleaf_source/main.tex` exists — if so, use it.
     2. Otherwise, glob for `Overleaf_source/*.tex`.
        - If exactly one `.tex` file is found, use it.
        - If multiple are found, use `AskUserQuestion` to present the list and ask the user which file is the primary manuscript. Wait for the answer before continuing.
3. **Generate a digest** — a compact structured summary saved to `<current_root>/_feeders/<feeder_name>_digest.md`:

```markdown
# Feeder: <feeder_name>
**Path:** <full path to feeder root>
**Registered:** <today's date>
**Last synced:** <today's date> (log through <date of most recent session in _ai_log.md>, git: <short SHA from feeder's code/ repo if available, else —>)

## What this project is about
<2-3 sentence summary: topic, method, current stage>

## Key methods & datasets
<bullet list — be specific, e.g. model names, dataset names, tools>

## Key findings so far
<bullet list of concrete results, even if preliminary>

## Relevance to current project
<1-2 sentences: why this feeder matters for the current project — infer from context>
```

4. **Update `_feeders.json`** in the current project root. Create it if it does not exist. Structure:
```json
{
  "Pub_YYY1": {
    "path": "C:\\...\\Pub_YYY1",
    "last_synced_date": "2026-04-04",
    "last_log_session": "2026-04-03",
    "digest_file": "_feeders/Pub_YYY1_digest.md"
  }
}
```
5. **Create `_feeders/`** folder in the current project root if it does not exist (use PowerShell: `New-Item -ItemType Directory`).

## After processing all feeders

Report to the user:
- Which feeders were registered
- A one-sentence summary of each (from the digest)
- Remind them that `/work` will now automatically check for updates at the start of each session
