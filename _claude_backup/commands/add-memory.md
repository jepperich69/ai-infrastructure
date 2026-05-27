# /add-memory — Add a specific file or note to the current project's feeder memory

Lighter-weight alternative to /family. Instead of digesting a whole project, the user points to a specific file, folder, or writes a free-text note to be stored as project memory.

## Argument parsing

`$ARGUMENTS` may be:
- A file path: `/add-memory C:\...\YYY1\code\model.py`
- A file path with a label: `/add-memory C:\...\YYY1\code\model.py "GP surrogate architecture"`
- A free-text note: `/add-memory "YYY1 uses a 3-layer GP surrogate trained on PMIP data"`
- A project name (adds the whole _ai_log.md): `/add-memory Pub_YYY1`

## Current project root

Walk up from the current working directory until you find a folder starting with `Pub_`, `Pro_`, or `PhD_`.

## What to do

1. **If a file path is given:**
   - Read the file (if large, read the first 150 lines — enough to capture structure and key content).
   - Generate a compact note (5-15 bullet points max) capturing what is useful for the current project.
   - Save to `_feeders/<descriptive_slug>.md` using the label or filename as the slug.

2. **If a project name is given:**
   - Read that project's `_ai_log.md` only (not the full handover).
   - Generate a brief digest of sessions and findings.
   - Save to `_feeders/<project_name>_digest.md`.
   - Register in `_feeders.json` so `/work` will monitor it for updates.

3. **If free text is given:**
   - Save it verbatim with a timestamp to `_feeders/notes.md` (append, don't overwrite).

## Note file format

```markdown
# Memory: <label or filename>
**Added:** <date>
**Source:** <file path or "manual note">

<bullet-point summary or verbatim note>
```

Report the slug of the file saved and its location.
