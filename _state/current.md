# State -- 2026-06-30
**Phase:** Active development -- v1.0 released; skills + verification tooling growing
**Last session:** Fixed the stale-PDF bug in `scripts/generate_docs.ps1` (helpi 16): Make-Pdf now uses a throwaway Edge `--user-data-dir`, deletes any prior PDF before rendering, and polls for the output, so a running browser can no longer serve a stale-but-fresh-timestamped render. Logged as known_issues #41 and validated with Edge open. Pushed (b2298ad).
**Next:** none open.
**Git ref:** b2298ad
**Agent:** Claude Opus 4.8
