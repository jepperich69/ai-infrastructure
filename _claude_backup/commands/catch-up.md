# research-catch-up -- Fix open known issues in the AI infrastructure

Sweep `known_issues.md` for open bugs and apply their documented fixes. This skill
is for the AI_auto infrastructure project. Run it at the start of any AI_auto session,
or when the user types `/catch-up`.

## What to do

1. **Read known_issues.md**
   Path: `C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto\known_issues.md`

2. **Identify open issues**
   Find every entry where the **Status** line reads `open`.
   If none exist: say "No open issues -- infrastructure is clean." and stop.

3. **For each open issue** (work through them in order):
   a. Read the **Affects:** field -- these are the file(s) to change.
   b. Read the **Fix:** field -- this is the authoritative description of what to do.
   c. Read each affected file.
   d. Apply the fix exactly as described. Do not over-engineer or expand scope.
   e. Verify the fix: re-read the changed section or run a quick sanity check.
   f. Update the issue status in `known_issues.md`:
      Change `**Status:** open` to `**Status:** fixed (YYYY-MM-DD)` using today`s date.

4. **Report** -- for each issue processed, one line:
   `Fixed #N: <title> -- <one-sentence summary of change>`

5. **Commit**
   ```powershell
   git -C "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto" add -A
   git -C "C:\Users\rich\OneDrive - Danmarks Tekniske Universitet\JR\AI_auto" commit -m "catch-up: fix open known issues"
   ```

## Rules

- Touch only files named in **Affects:** fields. Do not sweep other files.
- Do not touch `platform-fact` or `fixed` entries.
- Do not invent fixes -- only apply what the **Fix:** field says.
- If a fix cannot be applied safely (file missing, ambiguous instructions), skip it
  and report: `Skipped #N: <reason>` -- do not mark it fixed.
- This skill does not discover new issues -- that is the job of /close (step 3.2).