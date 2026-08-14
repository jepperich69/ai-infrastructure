"""
Machine verification of the derivations in
Kahneman & Tversky (1979), "Prospect Theory: An Analysis of Decision under Risk",
Econometrica 47(2), 263-292.

Method
------
The paper is a chain of stated implications of the form

    <premise the paper asserts>   ==>   <conclusion the paper asserts>

We do not attempt to prove the paper's psychology, its axiomatisation, or its
data. We check one thing, mechanically: does each stated conclusion follow from
the stated premise by the algebra claimed?

Formalisation. Write each inequality as a residual that the paper asserts is
positive (or zero, or non-negative). A valid one-step derivation from premise
residual P to conclusion residual C is exactly the existence of a POSITIVE
MULTIPLIER m with

    C == m * P     identically,     m > 0 under the paper's own assumptions.

SymPy is asked to close `simplify(C - m*P) == 0`. If it cannot, the step does not
follow as claimed. This is a certificate: the multiplier is printed for every
check, so a wrong formalisation is visible rather than hidden behind a PASS.

Concavity is used by the paper at several points. It is encoded as the midpoint /
chord inequality it actually is: for concave v with v(0)=0,

    v(lam*a) - lam*v(a)  >=  0      for 0 <= lam <= 1,

and the resulting residual is fed in as a premise like any other.

Run:  C:\\Users\\rich\\AppData\\Local\\miniconda3\\python.exe verify.py
"""

import sympy as sp

# ----------------------------------------------------------------------------
# reporting
# ----------------------------------------------------------------------------
ROWS = []
COUNT = {"PASS": 0, "FAIL": 0, "ERROR": 0, "FLAG": 0}


def record(label, bucket, ok, checked, got, note=""):
    verdict = "PASS" if ok is True else ("FLAG" if ok == "flag" else "FAIL")
    COUNT[verdict] += 1
    ROWS.append((label, bucket, verdict, checked, got, note))
    line = f"{label:34s} | {bucket:12s} | {verdict:4s} | checked: {checked} | got: {got}"
    if note:
        line += f" | note: {note}"
    print(line)


def implies(label, P, C, m, checked, note=""):
    """Certificate check: C == m*P identically (m > 0 by assumption)."""
    try:
        resid = sp.simplify(sp.together(sp.expand(C - m * P)))
        ok = (resid == 0)
        record(label, "IMPLICATION", ok, checked,
               f"C - m*P = {resid}  [m = {m}]", note)
        return ok
    except Exception as exc:                                  # pragma: no cover
        COUNT["ERROR"] += 1
        ROWS.append((label, "IMPLICATION", "ERROR", checked, str(exc), note))
        print(f"{label:34s} | IMPLICATION  | ERR  | {exc}")
        return False


def identity(label, expr, checked, note=""):
    try:
        resid = sp.simplify(sp.expand(expr))
        ok = (resid == 0)
        record(label, "IDENTITY", ok, checked, f"residual = {resid}", note)
        return ok
    except Exception as exc:                                  # pragma: no cover
        COUNT["ERROR"] += 1
        print(f"{label:34s} | IDENTITY     | ERR  | {exc}")
        return False


def numeric(label, computed, stated, checked, note=""):
    val = sp.nsimplify(computed)
    ok = sp.simplify(val - sp.nsimplify(stated)) == 0
    record(label, "NUMERIC", ok, checked, f"{sp.N(val, 10)} vs stated {stated}", note)
    return ok


# ----------------------------------------------------------------------------
# symbols.  All utilities / values of gains are positive; decision weights are
# positive and < 1; probabilities are in (0,1).  These are the paper's own
# assumptions (v(0)=0, pi(0)=0, pi(1)=1, pi increasing, v increasing).
# ----------------------------------------------------------------------------
u2400, u2500, u3000, u4000 = sp.symbols("u2400 u2500 u3000 u4000", positive=True)
v2000, v2400, v2500, v3000, v4000, v5, v5000, v6000 = sp.symbols(
    "v2000 v2400 v2500 v3000 v4000 v5 v5000 v6000", positive=True)
vm2000, vm4000, vm6000 = sp.symbols("vm2000 vm4000 vm6000", negative=True)
vx, vy, vpx = sp.symbols("vx vy vpx", positive=True)
vmx, vmy = sp.symbols("vmx vmy", negative=True)
pi25, pi33, pi34, pi45, pi66, pi90 = sp.symbols(
    "pi25 pi33 pi34 pi45 pi66 pi90", positive=True)
pi001, pi002 = sp.symbols("pi001 pi002", positive=True)
pi_p, pi_q, pi_pp, pi_qp, pi_h = sp.symbols(
    "pi_p pi_q pi_pp pi_qp pi_h", positive=True)
pi_pq, pi_pr, pi_pqr = sp.symbols("pi_pq pi_pr pi_pqr", positive=True)
pi_1mp = sp.symbols("pi_1mp", positive=True)
p, q, r = sp.symbols("p q r", positive=True)
u_wy, u_wry = sp.symbols("u_wy u_wry", positive=True)
f_x, f_y, f_y2 = sp.symbols("f_x f_y f_y2", positive=True)
R = sp.Rational

print("=" * 118)
print("Kahneman & Tversky (1979), Prospect Theory -- machine verification of the stated derivations")
print("=" * 118)

# ============================================================================
# SECTION 2 -- critique of expected utility
# ============================================================================
print("\n--- Section 2: critique of expected utility ---")

numeric("eq:p1-ev-A", R(33, 100) * 2500 + R(66, 100) * 2400, 2409,
        "0.33*2500 + 0.66*2400 + 0.01*0")
numeric("eq:p1-ev-A/dominance", sp.sign(R(33, 100) * 2500 + R(66, 100) * 2400 - 2400), 1,
        "E[A] - E[B] > 0  (the rejected prospect has the higher EV)")
numeric("eq:p2-ev/C", R(33, 100) * 2500, 825, "0.33*2500")
numeric("eq:p2-ev/D", R(34, 100) * 2400, 816, "0.34*2400")

# Allais, Problem 1: B > A under EU  ==>  .34u(2400) > .33u(2500)
P = u2400 - (R(33, 100) * u2500 + R(66, 100) * u2400)
C = R(34, 100) * u2400 - R(33, 100) * u2500
implies("eq:allais-eu", P, C, 1,
        "u2400 - (.33u2500 + .66u2400)  ->  .34u2400 - .33u2500")

# Problem 3: B=(3000) > A=(4000,.80)  ==>  u(3000)/u(4000) > 4/5
P = u3000 - R(80, 100) * u4000
C = u3000 / u4000 - R(4, 5)
implies("eq:p3-ratio", P, C, 1 / u4000,
        "divide u3000 - .8u4000 > 0 by u4000 > 0")

# Problem 4: C=(4000,.20) > D=(3000,.25)  ==>  u(3000)/u(4000) < 4/5
P = R(20, 100) * u4000 - R(25, 100) * u3000
C = R(4, 5) - u3000 / u4000
implies("eq:p4-ratio", P, C, 4 / u4000,
        "divide .2u4000 - .25u3000 > 0 by .25*u4000 > 0")

numeric("eq:p34-ev/A", R(80, 100) * 4000, 3200, "0.80*4000")
numeric("eq:p34-ev/C", R(20, 100) * 4000, 800, "0.20*4000")
numeric("eq:p34-ev/D", R(25, 100) * 3000, 750, "0.25*3000")

numeric("eq:p78-ev/P7", R(45, 100) * 6000 - R(90, 100) * 3000, 0,
        "E[(6000,.45)] - E[(3000,.90)]", "both equal 2700 -- EV cannot explain the choice")
numeric("eq:p78-ev/P8", R(1, 1000) * 6000 - R(2, 1000) * 3000, 0,
        "E[(6000,.001)] - E[(3000,.002)]", "both equal 6")

numeric("eq:reflect-var/EV", R(80, 100) * (-4000), -3200,
        "E[(-4000,.80)]", "-3200 < -3000, so (-3000) has the higher EV as stated")
numeric("eq:reflect-var/Var", R(80, 100) * R(20, 100) * 4000 ** 2, 2560000,
        "Var[(-4000,.80)] = p(1-p)x^2", "the sure loss has variance 0, so lower as stated")

# Probabilistic insurance under EU (p.270)
# premise, after the normalisation u(w-x)=0, u(w)=1:  u(w-y) = 1-p
prem_norm = sp.solve(sp.Eq(p * 0 + (1 - p) * 1, u_wy), u_wy)[0]
numeric("eq:probins-premise", prem_norm, 1 - p,
        "solve p*u(w-x) + (1-p)u(w) = u(w-y) with u(w-x)=0, u(w)=1")
G = ((1 - r) * p * 0 + r * p * (1 - p) + (1 - p) * u_wry) - (1 - p)
C = u_wry - (1 - r * p)
implies("eq:probins-reduce", C, G, (1 - p),
        "goal residual == (1-p) * [u(w-ry) - (1-rp)];  1-p > 0")

numeric("eq:p10-compound/a", R(25, 100) * R(80, 100), R(20, 100), "0.25*0.80")
numeric("eq:p10-compound/b", R(25, 100) * 1, R(25, 100), "0.25*1.00")

# Problems 11/12 in final states
numeric("eq:p1112-identity/A-hi", 1000 + 1000, 2000, "bonus 1000 + gain 1000")
numeric("eq:p1112-identity/A-lo", 1000 + 0, 1000, "bonus 1000 + gain 0")
numeric("eq:p1112-identity/C-hi", 2000 + 0, 2000, "bonus 2000 + loss 0")
numeric("eq:p1112-identity/C-lo", 2000 - 1000, 1000, "bonus 2000 - loss 1000")
numeric("eq:p1112-identity/B", 1000 + 500, 1500, "bonus 1000 + sure 500")
numeric("eq:p1112-identity/D", 2000 - 500, 1500, "bonus 2000 - sure 500")

# ============================================================================
# SECTION 3 -- theory
# ============================================================================
print("\n--- Section 3: theory ---")

identity("eq:eq2-form",
         (vy + pi_p * (vx - vy)) - (pi_p * vx + (1 - pi_p) * vy),
         "v(y) + pi(p)[v(x)-v(y)]  ==  pi(p)v(x) + [1-pi(p)]v(y)")

# eq (2) reduces to eq (1) iff pi(p) + pi(1-p) = 1
diff = sp.expand((pi_p * vx + (1 - pi_p) * vy) - (pi_p * vx + pi_1mp * vy))
sol = sp.solve(sp.Eq(diff, 0), pi_1mp)
record("eq:eq2-reduces", "SOLVE", sol == [1 - pi_p],
       "solve [1-pi(p)]v(y) - pi(1-p)v(y) = 0 for pi(1-p)",
       f"pi(1-p) = {sol[0]}  i.e.  pi(p)+pi(1-p) = 1")

# Problem 13: concavity for gains / convexity for losses
P = pi25 * (v4000 + v2000) - pi25 * v6000
C = (v4000 + v2000) - v6000
implies("eq:p13-concave", P, C, 1 / pi25, "divide by pi(.25) > 0")
P = pi25 * vm6000 - pi25 * (vm4000 + vm2000)
C = vm6000 - (vm4000 + vm2000)
implies("eq:p13-convex", P, C, 1 / pi25, "divide by pi(.25) > 0")

identity("eq:lossav",
         ((vy + vmy) - (vx + vmx)) - ((vmy - vmx) - (vx - vy)),
         "v(y)+v(-y) > v(x)+v(-x)  <=>  v(-y)-v(-x) > v(x)-v(y)")

P = (0 + 0) - (vx + vmx)          # y = 0, v(0) = 0
C = -vmx - vx
implies("eq:lossav-y0", P, C, 1, "set y=0 with v(0)=0  ->  v(x) < -v(-x)")

# Subadditivity, Problem 8 (p.281): first link
P = pi001 * v6000 - pi002 * v3000
C = pi001 / pi002 - v3000 / v6000
implies("eq:subadd/link1", P, C, 1 / (pi002 * v6000),
        "divide by pi(.002)*v(6000) > 0")

# second link: v(3000)/v(6000) > 1/2 "by the concavity of v"
# concavity certificate with v(0)=0 and lam=1/2, a=6000:
K = v3000 - R(1, 2) * v6000                     # >= 0 by concavity
C = v3000 / v6000 - R(1, 2)
implies("eq:subadd/link2", K, C, 1 / v6000,
        "concavity chord v(.5*6000) >= .5*v(6000)+.5*v(0), then divide by v(6000)",
        "chord gives >= ; the paper's strict > needs STRICT concavity")

# Problem 14 (p.281): overweighting of low probabilities
P = pi001 * v5000 - v5
C = pi001 - v5 / v5000
implies("eq:overweight/link1", P, C, 1 / v5000, "divide by v(5000) > 0")
K = v5 - R(1, 1000) * v5000                     # >= 0 by concavity, lam = .001
C = v5 / v5000 - R(1, 1000)
implies("eq:overweight/link2", K, C, 1 / v5000,
        "concavity chord v(.001*5000) >= .001*v(5000), then divide by v(5000)",
        "chord gives >= ; the paper's strict > needs STRICT concavity")
numeric("eq:overweight/ev", R(1, 1000) * 5000, 5, "E[(5000,.001)]")

# Subcertainty (p.282)
P1 = v2400 - (pi66 * v2400 + pi33 * v2500)
C1 = (1 - pi66) * v2400 - pi33 * v2500
implies("eq:subcert-1", P1, C1, 1, "collect v(2400) terms")
P2 = pi33 * v2500 - pi34 * v2400
C = 1 - pi66 - pi34
implies("eq:subcert-3", C1 + P2, C, 1 / v2400,
        "add the two positive residuals, divide by v(2400) > 0",
        "chained: uses both Problem 1 and Problem 2")

# Subproportionality (p.282)
vx_sub = pi_pq * vy / pi_p                      # from the equality premise
I = pi_pqr * vy - pi_pr * vx_sub                # >= 0 premise, x eliminated
C = pi_pqr / pi_pr - pi_pq / pi_p
implies("eq:subprop", I, C, 1 / (vy * pi_pr),
        "eliminate v(x) via pi(p)v(x)=pi(pq)v(y), divide by v(y)*pi(pr) > 0")

# Dominance / near-linearity of pi (p.284)
P = (pi_p * vx + pi_q * vy) - (pi_pp * vx + pi_qp * vy)
C = (pi_p - pi_pp) / (pi_qp - pi_q) - vy / vx
implies("eq:dominance", P, C, 1 / (vx * (pi_qp - pi_q)),
        "divide by v(x)*[pi(q')-pi(q)] > 0",
        "positivity of the multiplier needs pi increasing and q' > q")

# ============================================================================
# SECTION 4 -- discussion
# ============================================================================
print("\n--- Section 4: discussion ---")

# Allais condition (p.284), both halves
C = pi33 / pi34 - v2400 / v2500
implies("eq:allais-cond/upper", P2, C, 1 / (pi34 * v2500),
        "from Problem 2: divide pi33*v2500 - pi34*v2400 > 0 by pi34*v2500 > 0")
C = v2400 / v2500 - pi33 / (1 - pi66)
implies("eq:allais-cond/lower", C1, C, 1 / (v2500 * (1 - pi66)),
        "from Problem 1: divide by v2500*(1-pi66) > 0",
        "needs 1 - pi(.66) > 0")
identity("eq:allais-subcert",
         (pi33 / pi34 - pi33 / (1 - pi66)) * (pi34 * (1 - pi66) / pi33)
         - ((1 - pi66) - pi34),
         "the two-sided condition is non-empty iff pi(.34) < 1 - pi(.66)")

# Substitution-axiom condition (p.285), Problems 7 and 8
P = pi90 * v3000 - pi45 * v6000
C = v3000 / v6000 - pi45 / pi90
implies("eq:subst-cond/lower", P, C, 1 / (pi90 * v6000),
        "from Problem 7: divide by pi(.90)*v(6000) > 0")
record("eq:subst-cond/upper", "IMPLICATION", True,
       "same certificate as eq:subadd/link1", "reused", "not re-derived")

# Probabilistic insurance under prospect theory (p.285)
identity("eq:probins-pt-goal",
         (f_y2 + pi_h * (f_y - f_y2) + pi_h * (f_x - f_y2))
         - (pi_h * f_x + pi_h * f_y + (1 - 2 * pi_h) * f_y2),
         "the two forms of the RHS of the prospect-theory bound agree")

# the substitution f(y/2) -> f(y)/2 and f(x) -> f(y)/pi(p)
RHS_goal = pi_h * f_x + pi_h * f_y + (1 - 2 * pi_h) * f_y2
RHS_suff = (pi_h / pi_p) * f_y + pi_h * f_y + f_y / 2 - pi_h * f_y
identity("eq:probins-pt-suffices",
         RHS_goal.subs({f_x: f_y / pi_p, f_y2: f_y / 2}) - RHS_suff,
         "substitute f(x)=f(y)/pi(p) and f(y/2)=f(y)/2 into the bound")

# and the final reduction
G = RHS_suff - f_y
C = pi_h - pi_p / 2
implies("eq:probins-pt-final", G, C, pi_p / f_y,
        "multiply [RHS - f(y)] by pi(p)/f(y) > 0  ->  pi(p/2) - pi(p)/2")

# SIDE CONDITION the paper does not state: replacing f(y/2) by f(y)/2 only
# WEAKENS the bound if the coefficient (1 - 2*pi(p/2)) is non-negative.
gap = sp.simplify(RHS_goal - RHS_goal.subs(f_y2, f_y / 2))
record("eq:probins-pt-suffices/side", "SIDE-COND", "flag",
       "RHS(f(y/2)) - RHS(f(y)/2), using concavity f(y/2) >= f(y)/2",
       f"gap = {gap}",
       "sign of the gap requires 1 - 2*pi(p/2) >= 0, i.e. pi(p/2) <= 1/2 -- "
       "an assumption the paper does not state; if pi(p/2) > 1/2 the "
       "'it suffices to show' step reverses")

# Risk seeking for small probabilities (p.285)
P = pi_p * vx - vpx
C = pi_p - vpx / vx
implies("eq:riskseek", P, C, 1 / vx, "divide pi(p)v(x) > v(px) by v(x) > 0")
K = vpx - p * vx                                 # concavity chord, lam = p
C = vpx / vx - p
implies("eq:riskseek-necessary", K, C, 1 / vx,
        "concavity chord v(px) >= p*v(x) + (1-p)*v(0), divide by v(x) > 0",
        "chord gives >= ; the paper's strict > needs STRICT concavity")

# ============================================================================
print("\n" + "=" * 118)
n = COUNT["PASS"] + COUNT["FAIL"] + COUNT["ERROR"]
print(f"TOTALS: {n} checks run -- {COUNT['PASS']} passed, {COUNT['FAIL']} failed, "
      f"{COUNT['ERROR']} errored; {COUNT['FLAG']} side condition(s) flagged.")
print("NOT-CHECKABLE (recorded, not run): 6 -- response data; editing-phase "
      "definitions; the Appendix representation theorem; endpoint behaviour of pi; "
      "Figures 3-4; and the unproved assertion pi(p)>p & subproportionality => pi(rp)>r*pi(p).")
print("=" * 118)
