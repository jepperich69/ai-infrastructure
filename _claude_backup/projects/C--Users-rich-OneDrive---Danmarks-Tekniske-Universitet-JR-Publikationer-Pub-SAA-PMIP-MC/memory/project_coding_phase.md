---
name: Scientific pivot and Log-Sum RICH direction
description: Bracketing paper archived 2026-05-01; new direction is Log-Sum RICH framework
type: project
originSessionId: 3093423a-12c4-4cdb-814b-c7985c6d2a98
---
The SAA bracketing paper was concluded a dead end on 2026-05-01. The upper bound E_pi[F]>=z* holds for ANY distribution (trivially), and uncertain constraints trap MH chains undermining the computational advantage claim. Archived as `Pub_SAA_PMIP_MC_SAA_Bracket_Anchor.tex`.

**New direction: Log-Sum RICH** -- risk-sensitive sampler for stochastic MIPs.

**Why:** Gunnar Flotterod's observation that a Boltzmann law over the joint (x,xi) space marginalises to a log-sum energy in x alone. For Gaussian costs + binary x, this collapses to a linear deterministic cost (Markowitz structure). Furness/Sinkhorn solves the EROT relaxation with the loaded cost as input.

**Current working document:** `Overleaf_source/Pub_Logsum_Solver_v4.tex` — submission-ready as of 2026-05-20; pushed to Overleaf at 344665a (2026-05-21).

**Toy code:** `code/logsum_toy/toy_3x3.py` -- reproduces all tables.

**Verification code (added 2026-05-21):**
- `code/logsum_toy/verify_boltzmann_3x3.py` — Exp B (algebraic identity, zero error) + Exp A (MC convergence, scaled instance)
- `code/logsum_toy/verify_full_chain_3x3.py` — Exp C (full chain: hat_c at paper regimes, dual ascent → λ̂*=1.828 in 5 iterations, E[v]=1.500=τ)

**How to apply:** The bracketing codebase in `code/assignment/` is now legacy; new experiments go in `code/logsum_toy/`.

**Current status:** Full-chain verification block added to Section 4.2 of manuscript. Gunnar authorship decision pending; submission to MPC once resolved.
