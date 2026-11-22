# Change entries

This folder holds the unreleased changes for the next release. Each file describes one change: how big a version bump it warrants and what to say about it in the changelog. At release time [Changewrite](https://github.com/flipbook-labs/changewrite) combines every entry here into `CHANGELOG.md`, bumps the version, and deletes the entries it consumed.

## Adding an entry

Create a Markdown file in this folder. The filename is up to you — it only exists to make entries easy to browse — so name it after the change, for example `fix-release-permissions.md`:

```markdown
---
bump: minor
category: Features
kind: controls
---

Add support for Foo values so Bar can be Bazzed.
```

- **`bump`** (required) — how much to move the version: `major`, `minor`, or `patch`.
- **`category`** (required) — the heading this entry appears under in the changelog: `Features`, `Changes`, `Fixes`, `Dependencies`, or `Internal`. The changelog lists the headings in that order, as set by `categories` in [`changewrite.toml`](../changewrite.toml). Dependencies and Internal start collapsed in GitHub release notes.
- **`kind`** (required) — the part of Flipbook the change landed in, shown as a chip beside the entry. Pick one of the `[kind.*]` tables in [`changewrite.toml`](../changewrite.toml): `stories`, `sidebar`, `preview`, `controls`, `app`, `plugin`, `embedded`, `agents`, `telemetry`, `docs`, `build`, `tooling`, `packages`, `ci`, `release`, or `contributing`. A refactor takes the kind of whatever it touches.
- **Body** — everything below the frontmatter is the changelog text. Keep it to one short sentence, about 140 characters at most, written for someone reading the changelog without the pull request.

## How the version is chosen

The next version is the largest bump across all pending entries: a single `major` entry makes the release a major, otherwise a single `minor` makes it a minor, otherwise it is a `patch`. You do not pick the version directly; describe the impact of each change instead.

## Notes

- `README.md` is ignored, so it is safe to keep here.
- Entries are deleted once released; they live in this folder only while unreleased.
- The folder location is configurable via `unreleased_changes` in `changewrite.toml` and defaults to `./.changes/`.
