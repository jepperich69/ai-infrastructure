# State -- 2026-06-22
**Phase:** Active development -- v1.0 released; generic (non-paper) project support added
**Last session:** Made the agy v1.0.8 pin durable after it auto-reverted to the broken v1.0.10 -- set `AGY_CLI_DISABLE_AUTO_UPDATE=1` plus an ACL-deny backstop on the binary/folder. Wired AGENTS.md context into agy (it shares `~/.gemini`, auto-discovers AGENTS.md with cwd parent-traversal; global file hard-linked into agy's data root). Documented all in known_issues.md #37.
**Next:** User to verify interactively in a fresh terminal -- run `agy` in a project dir, confirm v1.0.8 + clean login + AGENTS.md loaded. If Developer Mode is enabled later, convert the global AGENTS.md hard link to a symlink.
**Git ref:** --
**Agent:** Claude Opus 4.8
