# Designed, not built

Infrastructure ideas that have been thought through far enough to be worth
keeping, but not implemented. Each entry records the design and, more
importantly, why it takes the shape it does. Delete an entry when it ships or
when it is decided against, recording which.

---

## 1. Dataflow pipeline visualiser (`helpi 30` candidate)

**Proposed 2026-08-27. Status: not started.**

### What it is

Look at a program as a routing of data through a calculation pipeline: what it
reads, what it computes, which external tools it calls, what it dumps, and what
it finally delivers. Nodes are data artifacts and tools, edges are flow, node
shading is time spent. Clicking a node opens the source at the line responsible.
Optionally replayable as an animation, since the trace is timestamped.

### Why this is not the same as a code browser

Sourcetrail (archived 2021) and Understand by SciTools are *symbol*-level:
functions, classes, call hierarchies. They answer "who calls this". They do not
answer "where does the data go and what does it cost". For a pipeline like
StopGeometry -- OSM cache to igraph to seeded route sample to metrics to CSV --
the dataflow view is the useful one and the call graph is noise.

### Why it must observe at runtime, not parse

Dataflow cannot be reliably inferred statically in Python: a path built by
string concatenation at run time is invisible to a parser. Instrument the
boundary calls instead and record what actually happened.

| Boundary intercepted | Becomes |
|---|---|
| `open`, `pd.read_*` / `to_*`, `nx.read_graphml` | input / output data node |
| `subprocess`, `urllib` / `requests` | external tool or API node |
| `gurobipy.Model.optimize` | solver node, with solve time |
| sampling timer or Scalene | node shading by time |

Each event records artifact, duration, and source file plus line.

### Click-through mechanism

`vscode://file/C:/path/analyze.py:568` opens VS Code at that line directly from
a browser. No editor plugin needed.

### Known limitation, stated up front

A runtime trace shows what *that run* did, not everything the program can do; an
untaken branch does not appear. For bottleneck hunting this is not a limitation,
because bottlenecks are runtime facts. For code comprehension it is, which is
why this complements a symbol browser rather than replacing it.

### The alternative that was rejected, and why

Dagster (1.13.20) and Snakemake (9.26.0) already render exactly this picture,
maintained and mature, with click-through to code and per-node timings. Both
require the pipeline to be expressed in their idiom -- decorated assets or
input/output rules. Across 113 projects that restructuring is not going to
happen. For a single paper's pipeline it is roughly an afternoon and carries a
real reproducibility benefit, so it stays the right answer whenever one pipeline
is being productionised rather than merely understood.

### Suggested first step

Bounded prototype, not infrastructure: a tracer plus an HTML view, run against
`Pub_StopGeometry_TBA\Code\analyze.py --cities Copenhagen`. Judge whether the
picture is actually useful before it becomes `helpi 30`. If the diagram turns
out to be a boring straight line, that is a cheap and useful negative result.
