---
name: pending_edits_v3
description: Pending Section 1 xi-definition expansion for v3 — SAA-contrast note added 2026-05-13; full ξ/SAA-contrast paragraph expansion still not applied
metadata: 
  node_type: memory
  type: project
  originSessionId: 539b9b4e-6ad4-4f9e-9f7e-c7ecf6c4320c
---

# Pending edits — Pub_Logsum_Solver_v3.tex

## Status as of 2026-05-13 session

The SAA-contrast note in Section 1 was addressed in the 2026-05-13 session by adding
a two-beat paragraph after the SAA/chance-constraint difficulty paragraph (see _ai_log).

The full ξ-definition expansion below was NOT applied — still pending.

## Problem class paragraph — full xi expansion

Replace current sentence:
> Let $\xi$ be an exogenous random scenario taking values in the scenario space $\Xi$, with distribution $P$ on $\Xi$.

With the richer version:

> Let $\xi\in\Xi\subseteq\mathbb{R}^d$ be a random vector drawn from a distribution $P$ over a scenario space $\Xi$; its components represent exogenous uncertain parameters --- travel times, unit costs, demands, available capacities --- that enter both the objective and the constraints but lie outside the decision-maker's control. Treating all randomness as a single distributional object $(\xi,P)$ is the most general statement: $P$ may be a continuous parametric family (e.g.\ Gaussian, as specialised in Section~\ref{sec:gaussian}), a finite discrete distribution over an enumerated scenario library, or the empirical measure over a sample $\{\xi^s\}_{s=1}^S$ --- in which case the expectation in~\eqref{eq:smip} reduces to a scenario average and the formulation subsumes SAA. The present framework differs from SAA in that it operates on $P$ analytically, through its first two moments, rather than iterating over realisations.

Also add `\label{sec:gaussian}` to `\section{Gaussian tractability: the mean-plus-variance form}`.

**Why:** Makes ξ concrete (random vector in R^d, named components), establishes single-distribution framing as maximally general with SAA as a special case, and distinguishes analytic moment-based approach from scenario enumeration.
