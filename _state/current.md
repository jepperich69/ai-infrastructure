# State -- 2026-06-22
**Phase:** Active development -- v1.0 released; generic (non-paper) project support added
**Last session:** Fixed broken interactive Gemini/Antigravity access -- root cause was a Google OAuth regression in agy v1.0.9/1.0.10 (not firewall/account); downgraded agy to v1.0.8 (login works, caches as Google AI Pro / 3.5 Flash). Formalized the two-track model convention: interactive = agy (3.5 Flash, subscription), automation (Forum + pipeline) = classic gemini hard-pinned to 2.5-flash on the free API key. Fixed the unpinned gemini round in the /pipeline skill; documented everything in known_issues.md #36/#37 and global CLAUDE.md.
**Next:** none. Watch for agy auto-updating back to 1.0.10 (re-swap 1.0.8 if login breaks). Optionally enable billing on the API key if 3.x is ever wanted inside automation.
**Git ref:** --
**Agent:** Claude Opus 4.8
