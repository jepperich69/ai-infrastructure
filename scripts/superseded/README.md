# superseded/

Retired versions of infrastructure files, kept so a change can be read against
what it replaced.

**This folder IS tracked by git.** That is worth stating, because every other
underscore-prefixed folder here (`_claude_backup/`, `_pipelines/`, `_forums/`,
`_state/`) is gitignored, and the name was chosen without the underscore
specifically to avoid being read as one of those.

## Why this exists

`~/.claude/` is not a git repository. Its contents are backed up by
`sync_claude_config.ps1 -Backup` (a Stop hook, every session) into
`scripts/_claude_backup/`, which OneDrive replicates and `helpi 20` restores.
That protects against machine loss, but `_claude_backup/` is gitignored by
deliberate decision, so it gives no version history: the backup is overwritten
each session and the previous version is gone from disk.

So when a `~/.claude/` file is materially rewritten, put the outgoing version
here before the next Stop hook overwrites the only copy.

## Naming

`<name>.superseded-<YYYY-MM-DD>.md`, where the date is when it was replaced,
not when it was written.

## Contents

- `close.superseded-2026-08-01.md` -- the `/close` command as it stood from
  2026-06-17 to 2026-08-01. Replaced because its step F ("Update project
  CLAUDE.md") invited every session's findings into the project instruction
  file. That drove `Pub_PMIP_VSP/.claude/CLAUDE.md` to 153,187 chars, past the
  150k loading limit, growing 45,800 chars/day. The replacement separates
  findings (which go to a project record document) from rules (which are the
  only thing CLAUDE.md keeps), and adds a size check. It also fixes a
  hardcoded `Claude Sonnet 4.6` agent name in steps B and E.
