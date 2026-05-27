---
name: PMIP_VSP future direction — iterative column generation + entropy projection
description: Deferred idea for Pub_PMIP_VSP paper: re-solve LP periodically as MH generates new columns
type: project
originSessionId: e860086f-c418-45a7-aefa-40d74226fedd
---
After cold-start experiment is done, the next ambitious step is a fully iterative algorithm:

1. Start from a thin pool (singletons or random greedy)
2. Run Sinkhorn LP → greedy round → MH chain
3. As MH generates new routes dynamically, add them back to the pool
4. Re-solve the LP with the expanded pool to update Boltzmann weights
5. Use updated weights to guide MH proposals (bias toward high-probability columns)
6. Repeat until convergence

**Why:** This is genuine column-generation + entropy projection. The LP is not a one-shot step but the iterative engine. Each LP re-solve updates the probability landscape and tells the MH where to look next. This is closer to what "projection PMIP" should mean theoretically.

**Why it matters for the paper:** If this works, the contribution is an algorithm that needs no problem-specific warm-start and no SA — the entropy projection IS the search. The comparison with ten Bosch et al. (SA + restricted MIP) becomes genuinely clean: their method requires SA to pre-explore; ours does not.

**Suggested experiment sequence:**
1. Cold start (singletons only, no LP re-solve) — in progress
2. Cold start + random greedy pool (cheap, no SA)
3. Iterative: cold start + periodic LP re-solve as MH adds columns
4. Compare all three against SA-warmed version across all 7 instances

**How to apply:** This is the "killer app" framing for Pub_PMIP_VSP. Do not implement until cold-start baseline is benchmarked.
