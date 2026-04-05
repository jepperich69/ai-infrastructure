# Releasing a new version of the infrastructure

This is a lightweight process designed for one maintainer, not a software team.

---

## The two lines

| Line | Branch | Purpose |
|------|--------|---------|
| Stable | `main` | What you rely on day-to-day. Tagged at each release. |
| Development | `develop` | Where larger changes accumulate before the next release. |

You do not need to use branches for small fixes — committing directly to `main` is fine.
Use `develop` when you are in the middle of something larger that is not yet ready to trust.

---

## Current state: v0.2

The infrastructure was tagged `v0.2` on 2026-04-05.
To see it: `git show v0.2`

Previous stable release: `v0.1` (2026-04-05) — `git show v0.1`

---

## Working toward v0.3

1. Make changes — edit scripts, update docs, add commands.
2. Commit as you go: `git add <file>` then `git commit -m "short description"`.
3. Update the `[Unreleased]` section in `CHANGELOG.md` as you go.
4. Test the changes in a real session before promoting.

If the changes are large or experimental, do them on `develop`:
```
git checkout develop
# ... make changes, commit ...
git checkout main
git merge develop
```

---

## Promoting to the next stable version (e.g. v0.3)

1. Move the `[Unreleased]` section in `CHANGELOG.md` to `[v0.3] — YYYY-MM-DD`.
2. `VERSION` is the single source of truth — update it to contain `v0.3`.
3. Update the version field in `infrastructure.html` (search for `Infrastructure version`).
4. Commit: `git commit -m "Release v0.3"`
5. Tag it: `git tag v0.3`

That is the entire release process.

---

## Recovering an old version

```
git log --oneline          # find the commit or tag you want
git show v0.1:helpi.ps1    # inspect a file from a past release
git checkout v0.1 -- helpi.ps1  # restore one file from a past release
```

Do not force-push or rewrite history. Tags are permanent markers.
