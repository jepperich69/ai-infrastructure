# Math verification report — Kahneman & Tversky (1979), *Prospect Theory*

- **Source:** Kahneman, D. and Tversky, A. (1979). Prospect Theory: An Analysis of Decision under Risk. *Econometrica* 47(2), 263–292.
- **Transcription:** `KT1979_claims.tex` (claims copied verbatim from the PDF, with page numbers)
- **Script:** `verify.py` (re-runnable, SymPy 1.14.0)
- **Raw output:** `verify_output.txt`
- **Run:** 2026-08-14

**Totals: 49 checks run — 49 passed, 0 failed, 0 errored; 1 side condition flagged; 6 claims recorded NOT-CHECKABLE.**

The paper's algebra holds. Every stated implication follows from its stated premise. The audit surfaced one *unstated side condition* and three places where a strict inequality is asserted from a weak (chord) concavity argument.

---

## Method

The paper is a chain of stated implications, `premise ⟹ conclusion`. We check one thing mechanically: does each conclusion follow from its premise by the algebra claimed?

Each inequality is written as a residual the paper asserts is positive. A valid one-step derivation from premise residual `P` to conclusion residual `C` is exactly the existence of a **positive multiplier** `m` with

```
C == m * P   identically,    m > 0 under the paper's own assumptions.
```

SymPy is asked to close `simplify(C - m*P) == 0`. The multiplier is printed for every check, so a wrong formalisation is visible rather than hidden behind a green PASS.

Concavity of `v` is encoded as the chord inequality it actually is: for concave `v` with `v(0)=0`, `v(λa) − λv(a) ≥ 0` for `λ ∈ [0,1]`. That residual is then fed in as a premise like any other.

---

## Results

| Label | Type | Result | What was checked | Certificate |
|---|---|---|---|---|
| `eq:p1-ev-A` | NUMERIC | PASS | 0.33·2500 + 0.66·2400 + 0.01·0 | 2409 — the *rejected* prospect has the higher EV |
| `eq:p2-ev` | NUMERIC | PASS | 0.33·2500; 0.34·2400 | 825; 816 |
| `eq:allais-eu` | IMPLICATION | PASS | u(2400) > .33u(2500)+.66u(2400) ⟹ .34u(2400) > .33u(2500) | m = 1 |
| `eq:p3-ratio` | IMPLICATION | PASS | u(3000) > .8u(4000) ⟹ u(3000)/u(4000) > 4/5 | m = 1/u(4000) |
| `eq:p4-ratio` | IMPLICATION | PASS | .2u(4000) > .25u(3000) ⟹ reverse | m = 4/u(4000) |
| `eq:p34-ev` | NUMERIC | PASS | 3200; 800; 750 | all match |
| `eq:p78-ev` | NUMERIC | PASS | E[(6000,.45)] − E[(3000,.90)]; E[(6000,.001)] − E[(3000,.002)] | 0; 0 — EV is silent on both pairs |
| `eq:reflect-var` | NUMERIC | PASS | E[(−4000,.80)]; Var[(−4000,.80)] | −3200; 2 560 000 |
| `eq:probins-premise` | SOLVE | PASS | solve p·u(w−x)+(1−p)u(w) = u(w−y), u(w−x)=0, u(w)=1 | u(w−y) = 1−p |
| `eq:probins-reduce` | IMPLICATION | PASS | goal ⟺ u(w−ry) > 1−rp | m = 1−p |
| `eq:p10-compound` | NUMERIC | PASS | .25×.80; .25×1.00 | .20; .25 |
| `eq:p1112-identity` | NUMERIC | PASS (6) | bonus arithmetic in final states | A = C = (2000,.50; 1000,.50); B = D = 1500 |
| `eq:eq2-form` | IDENTITY | PASS | v(y)+π(p)[v(x)−v(y)] = π(p)v(x)+[1−π(p)]v(y) | residual 0 |
| `eq:eq2-reduces` | SOLVE | PASS | when does Eq. (2) reduce to Eq. (1)? | π(1−p) = 1−π(p) |
| `eq:p13-concave` / `-convex` | IMPLICATION | PASS (2) | divide out π(.25) | m = 1/π(.25) |
| `eq:lossav` | IDENTITY | PASS | v(y)+v(−y) > v(x)+v(−x) ⟺ v(−y)−v(−x) > v(x)−v(y) | residual 0 |
| `eq:lossav-y0` | IMPLICATION | PASS | set y=0, v(0)=0 ⟹ v(x) < −v(−x) | m = 1 |
| `eq:subadd/link1` | IMPLICATION | PASS | π(.001)v(6000) > π(.002)v(3000) ⟹ ratio inequality | m = 1/[π(.002)v(6000)] |
| `eq:subadd/link2` | IMPLICATION | PASS\* | v(3000)/v(6000) > 1/2 by concavity | chord at λ=1/2; **gives ≥, not >** |
| `eq:overweight/link1` | IMPLICATION | PASS | π(.001)v(5000) > v(5) ⟹ π(.001) > v(5)/v(5000) | m = 1/v(5000) |
| `eq:overweight/link2` | IMPLICATION | PASS\* | v(5)/v(5000) > .001 by concavity | chord at λ=.001; **gives ≥, not >** |
| `eq:subcert-1` | IMPLICATION | PASS | collect v(2400) terms | m = 1 |
| `eq:subcert-3` | IMPLICATION | PASS | add both residuals ⟹ π(.66)+π(.34) < 1 | m = 1/v(2400) |
| `eq:subprop` | IMPLICATION | PASS | eliminate v(x), divide by v(y)π(pr) | m = 1/[v(y)π(pr)] |
| `eq:dominance` | IMPLICATION | PASS | ⟹ [π(p)−π(p′)]/[π(q′)−π(q)] > v(y)/v(x) | m = 1/{v(x)[π(q′)−π(q)]} |
| `eq:allais-cond/upper` | IMPLICATION | PASS | from Problem 2 | m = 1/[π(.34)v(2500)] |
| `eq:allais-cond/lower` | IMPLICATION | PASS | from Problem 1 | m = 1/[v(2500)(1−π(.66))] |
| `eq:allais-subcert` | IDENTITY | PASS | the two-sided condition is non-empty iff π(.34) < 1−π(.66) | residual 0 |
| `eq:subst-cond` | IMPLICATION | PASS (2) | Problems 7 and 8 bracket v(3000)/v(6000) | m = 1/[π(.90)v(6000)] |
| `eq:probins-pt-goal` | IDENTITY | PASS | the two forms of the prospect-theory bound agree | residual 0 |
| `eq:probins-pt-suffices` | IDENTITY | PASS | substitute f(x)=f(y)/π(p), f(y/2)=f(y)/2 | residual 0 |
| `eq:probins-pt-final` | IMPLICATION | PASS | reduces to π(p)/2 ≤ π(p/2) | m = π(p)/f(y) |
| **`eq:probins-pt-suffices/side`** | **SIDE-COND** | **FLAG** | sign of the discarded gap | see below |
| `eq:riskseek` | IMPLICATION | PASS | π(p)v(x) > v(px) ⟺ π(p) > v(px)/v(x) | m = 1/v(x) |
| `eq:riskseek-necessary` | IMPLICATION | PASS\* | v(px)/v(x) > p by concavity | chord at λ=p; **gives ≥, not >** |

\* algebra passes; see *Strictness* below.

---

## Flagged side condition

**`eq:probins-pt-suffices/side` — p. 285, the prospect-theory proof that regular insurance is preferred to probabilistic insurance.**

The paper bounds
```
V = π(p/2)f(x) + π(p/2)f(y) + [1 − 2π(p/2)]·f(y/2)
```
and then says "using the concavity of f, it suffices to show" the same expression with `f(y/2)` replaced by `f(y)/2`. Concavity does give `f(y/2) ≥ f(y)/2`, so the replacement lowers that term.

SymPy computes the discarded gap exactly:
```
gap = (f_y − 2·f_y2) · (π(p/2) − 1/2)
```
Concavity forces the first factor `≤ 0`. The gap is therefore non-negative — the direction the argument needs — **only if `π(p/2) ≤ 1/2`.**

The paper never states this. It is a mild condition (the same paper's Figure 4 shows π below the diagonal over most of the range), but it is an assumption, not a consequence, and the proof as written does not carry it. If `π(p/2) > 1/2`, the "it suffices to show" step runs the wrong way and the reduction to `π(p)/2 ≤ π(p/2)` is not licensed.

This is precisely the class of thing the check exists to find: not an arithmetic slip, but a step where a substitution is made without recording the condition that makes it valid.

---

## Strictness

Three checks (`eq:subadd/link2`, `eq:overweight/link2`, `eq:riskseek-necessary`) assert a **strict** inequality from concavity. The chord inequality for a concave function gives `≥`. The strict form requires *strict* concavity, which the paper assumes informally (`v″(x) < 0`) but does not invoke at these points. Not an error — a gap between the hypothesis used and the hypothesis stated.

---

## Not machine-checkable

Recorded so the boundary of the audit is explicit; none was marked PASS or FAIL.

| Claim | Reason |
|---|---|
| Response percentages, N, significance at .01 | Data, not derivations. |
| Editing-phase operations (coding, combination, segregation, cancellation, simplification, dominance detection) | Definitions of a psychological process. |
| Existence and uniqueness of π and a ratio-scale v satisfying Eq. (1) (Appendix) | A representation theorem, not a computation. |
| "π is not well behaved near the endpoints"; the quantal effect | Qualitative modelling assertions. |
| Figures 3 and 4 | Hypothetical illustrations, explicitly not claims. |
| "It can be shown that if π(p) > p and subproportionality holds, then π(rp) > rπ(p)" | Asserted without derivation in the source; there is no argument to check. |

---

## Caveat

All results are conditional on the transcription in `KT1979_claims.tex` and the SymPy formalisation shown in the certificate column. The premises are the paper's own stated modal preferences; nothing was added or repaired. The verdict is about the algebra connecting the paper's statements, not about the psychology, the experimental design, or the axiomatisation.
