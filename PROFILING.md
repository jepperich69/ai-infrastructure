# Profiling and code visualisation

How to find out where a slow script actually spends its time, and how to draw
the structure of a codebase. Written 2026-08-27.

Tools are installed in miniconda `base`:
`scalene` 2.3.0, `py-spy` 0.4.2, `viztracer` 1.1.1, `pydeps` 3.0.7,
plus Graphviz 16.0.0 at `C:\Program Files\Graphviz\bin\dot.exe`.

> **Scalene must live in the same interpreter that runs the code.** It is in
> `base`. To profile something that runs under `pyopt` or a project venv,
> `pip install scalene` into that environment too. `py-spy` is exempt: it
> attaches to any process by PID and does not care which interpreter it is.

---

## The loop

**Measure, read, change one thing, measure again.** Never optimise code you
have not measured, and never trust a speedup you have not re-measured.

### 1. Baseline

```powershell
Measure-Command { python analyze.py --cities Copenhagen }
```

Write the number down. Without it you cannot tell whether a change helped.

### 2. Find where the time goes

```powershell
scalene --html --outfile prof.html analyze.py --cities Copenhagen
```

Opens a line-level table in the browser. Profile a **representative slice**, not
the whole job: one city, not 67. Scalene costs roughly 1.2-2x, so profiling the
full run means waiting an hour to learn what one city tells you in a minute.

### 3. Read it -- Python time vs native time

This is the column that matters and the reason to use Scalene over `cProfile`.

| What you see | What it means | What to do |
|---|---|---|
| Mostly **Python** time | Interpreter overhead in your own code | Optimise it, see below |
| Mostly **native** time | Time is inside C: Gurobi, numpy, GDAL | Your Python is irrelevant |

`cProfile` charges native time to the Python line that called it, so a Gurobi
solve looks like one slow Python line and you spend a day optimising the wrong
thing. With `gurobipy` at 278 import sites across the projects, this distinction
is the whole game.

If the answer is "94% native inside a solve", the fix is a better formulation, a
tighter bound, or a time limit. Not faster Python.

### 4. The three levers, in order

**Do less work.** Always try this first, and it needs no new library. The usual
finding is a pure function at the bottom of three nested loops that recomputes
something belonging to the *data* rather than the *iteration*. Hoist it into a
dict computed once. Tens of millions of calls become tens of thousands.

**Cache.** `functools.lru_cache` on a genuinely pure function is two lines. Check
that it does not read mutable state first.

**Move to native.** Vectorise with numpy, or `numba.njit` (already in `base`).
Last resort: biggest change, easiest to get subtly wrong.

### 5. Re-measure, then prove the numbers did not move

The step people skip. See `known_issues.md` #45: installing scikit-learn once
silently changed an optional k-means branch and moved the cluster labels.

```powershell
# before optimising, keep the output
python analyze.py --cities Copenhagen     # save results/nsd_summary_bike.csv
# after
python analyze.py --cities Copenhagen
# diff the two - they must be byte-identical
```

A speedup that changes the results is a bug, not a speedup. Seeded sampling
makes this check exact; where it is not exact, compare to tolerance.

---

## py-spy: the already-running process

Scalene has to launch the process. `py-spy` attaches to one that is already
going, which is the only option when the slow behaviour appears in the full run
and not in a single-city test.

```powershell
py-spy dump --pid 12345                  # where is it right now, one snapshot
py-spy record --pid 12345 -o flame.svg   # sampled flame graph until Ctrl-C
py-spy top --pid 12345                   # live, like top(1)
```

Find the PID with `Get-Process python | Select-Object Id, StartTime, CPU`.

Use this when a 67-city run has been going an hour and you want to know whether
it is stuck on city 4 or working through city 60, without killing it.

---

## viztracer: the timeline

When you want to see *ordering and duration* rather than totals -- which stage
of a pipeline dominates, whether something runs twice.

```powershell
viztracer analyze.py --cities Copenhagen     # writes result.json
vizviewer result.json                        # opens an interactive timeline
```

Zoomable and clickable. Heavier than Scalene, so keep the run short.

---

## pydeps: module structure

Draws the import graph. Needs Graphviz, which is installed but **not on PATH**,
so add it for the session first:

```powershell
$env:PATH += ";C:\Program Files\Graphviz\bin"
pydeps analyze.py --max-bacon 2 --cluster -o deps.svg
```

`--max-bacon 2` limits the graph to two hops from the entry point, which is the
difference between a readable diagram and a hairball. `--cluster` groups by
package. Open the SVG in a browser.

To make Graphviz permanent instead of per-session:
`setx PATH "$env:PATH;C:\Program Files\Graphviz\bin"` -- but note the user PATH
already contains a bare `.` entry that is worth removing first (known_issues #50).

---

## Quick reference

| Question | Tool |
|---|---|
| Which lines are slow? | `scalene --html --outfile prof.html script.py` |
| Is it my Python or a C library? | Scalene's Python vs native columns |
| What is this running job doing *now*? | `py-spy dump --pid <id>` |
| Why is the whole pipeline slow? | `viztracer` then `vizviewer` |
| What imports what? | `pydeps script.py --max-bacon 2 -o deps.svg` |
| Did my speedup break the results? | diff the output files |

---

## What is not installed, and why

`memray` is Linux and macOS only. `code2flow` needs a Graphviz round-trip and
overlaps with pydeps; add it only if function-level call graphs are needed.
Sourcetrail, the interactive click-through codebase browser this most resembles,
was archived in 2021 and has no maintained equivalent.
