# /snapshot — Git-tag the full Overleaf source as a named version

The user wants a version checkpoint of the manuscript before a major rewrite, reviewer round, or submission.

## What this does

Calls `snapshot.ps1` which creates an **annotated git tag** on `Overleaf_source/`. This captures the complete state: all .tex files, .bib bibliography, figures, style files, and subdirectories — everything in the repo at that moment. No file copying; no disk waste.

## Argument parsing

`$ARGUMENTS` may be:
- `V2` — explicit version label
- `V2 before-reviewer-cuts` — version + description (combined as `V2-before-reviewer-cuts`)
- empty — auto-increments (finds highest existing snapshot-v* tag, adds 1)

## Project root detection

Walk up from CWD until a folder starting with `Pub_`, `Pro_`, or `PhD_` is found.

## What to do

Run via PowerShell:
```
& "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\snapshot.ps1" -Project <name> [-Tag <label>]
```

If `$ARGUMENTS` contains a description after the version (e.g. `V2 before-reviewer-cuts`), combine them: `-Tag "V2-before-reviewer-cuts"`.

Report the output to the user. Remind them:
- `git tag -l "snapshot-*"` in Overleaf_source/ lists all snapshots
- `git diff snapshot-v2 HEAD` shows what changed since that point
- `git checkout snapshot-v2 -- main.tex` restores a single file
