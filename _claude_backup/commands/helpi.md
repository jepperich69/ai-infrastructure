# /helpi — Run a helpi infrastructure command inline

## Step 1 — Resolve the project

Before running anything, identify the target project. Work through these sources in order and stop at the first confident match:

1. **Explicit argument** — the user typed a project name (starts with `Pub_`, `Pro_`, or `PhD_`) in their message. Use it directly.

2. **Conversation context** — scan back through this conversation for any project name (pattern: `(Pub|Pro|PhD)_\S+`). Collect all candidates. Pick the **most recently referenced** one. File paths, `/work` calls, and filenames all count.

3. **Files touched this session** — look at any files you have Read or Edited. Extract the project name from the path (the segment matching the pattern above). Most-recently-touched wins.

4. **Current working directory** — check if the CWD contains a segment matching `(Pub_|Pro_|PhD_)`. If so, use that segment.

5. **State file fallback** — read `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\_state\last_project.txt`.

If you find a project via sources 2–5, **state it clearly** before running — e.g.:
> Using project **Pub_AssesTiming_Raoul_TBA** (from files opened this session). Run? [Y/n]

Wait for confirmation only if you are not confident (e.g. two different projects appeared in the conversation). If you are confident and the user seems to expect it to just run, proceed without asking.

If no project can be determined and the command needs one, ask the user directly.

## Step 2 — Command-specific pre-flight

Some commands need extra context resolved before running:

**Command 24 (one-pager):** The script cannot show a GUI dialog inside Claude Code. You must identify the source `.tex` file and pass it explicitly. To do this:
1. List the files in the project's `Overleaf_source/` directory.
2. Exclude files matching `^(slides|response|technical_onepager)` (case-insensitive).
3. Pick `main.tex` if it exists; otherwise pick the most recently modified `.tex` file.
4. Tell the user which file you picked, then run with it appended as the third argument.

Example: `helpi 24 Pub_MyPaper_TBA main.tex -Force`

## Step 3 — Run the command

Once the project (and any extra args) are known, run:

```
helpi $ARGUMENTS $PROJECT [-EXTRA_ARGS] -Force
```

Pass the project explicitly so `helpi.ps1` does not have to guess from CWD.

If the user's arguments already contain a project name, do not add it a second time.

Report the full output back to the user.
