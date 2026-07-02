# State -- 2026-07-02
**Phase:** Active development -- jr_optlib built + broadly populated (transport, sampling, VSP, NLP, routing, population, entropic-QP, DP, choice, RL); all primitives oracle-backed
**Last session:** Verified Gemini's DP/choice/RL additions, added the missing oracles + tests (suite 117 -> 128 pass), repaired the registry (invariant + a YAML parse error), documented the workflow in global CLAUDE.md, and reconciled + pushed every repo touched today once Overleaf came back (two divergences merged non-destructively).
**Next:** rewire papers to import jr_optlib one at a time as each is reopened (differential vs old copy, then delete local copy); add VERIFICATION.md + per-paper reproducibility/verification statements; replace expired gurobi.lic.
**Git ref:** af92321 (AI_auto); jr_optlib @ d565b8c
**Agent:** Claude Opus 4.8
