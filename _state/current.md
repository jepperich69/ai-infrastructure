# State -- 2026-07-02
**Phase:** Active development -- v1.0 released; skills + verification tooling growing
**Last session:** Design phase for a general code-robustness system (no code written yet). Agreed a shared `jr_optlib` OR library + three-registry index (vetted fns / known-answer instances / reference impls) + oracle bank, reconciling reuse with per-paper reproducibility via version-pin + submission-freeze. Found a real hazard: `mip_hybrid` duplicated 6x with drift across paper repos. Also confirmed the Overleaf git server (git.overleaf.com) is down (outage; GitHub fine). Full design in memory `project_robustness_system.md`.
**Next:** Build session (fresh chat): (1) site + index schema for `jr_optlib` (own project via helpi 27); (2) pilot-extract `ipf_2d` with a scipy/POT + marginal-invariant oracle; (3) oracle bank with rail582 wired to one check end-to-end. Later: migrate papers one at a time via library-vs-old-copy comparison. Open: delivery form (/verify-model skill vs helpi command vs both).
**Git ref:** 701c36a
**Agent:** Claude Opus 4.8
