---
aliases: [Changewrite]
linter-yaml-title-alias: Changewrite
---

# Changewrite

[Changewrite](https://github.com/flipbook-labs/changewrite) is a GitHub Action and Lute CLI for managing release cycles across flipbook-labs repos. It replaces the traditional "edit CHANGELOG.md and bump the version by hand" workflow with a PR-driven process where each contributor adds a small changelog entry alongside their code changes.

## How It Works

Contributors add `.md` files to a `.changes/` directory. Each entry describes what changed and declares which semver component to bump:

```markdown
---
version: minor
---

Brief description of the changes being made.

More details if necessary.
```

When it's time to release, the Action collects all pending entries, determines the next version (the highest bump type wins: any `major` → `x.0.0`, any `minor` → `x.y.0`, otherwise `x.y.z`), bundles them into `CHANGELOG.md`, and opens a draft publish PR. Merging that PR creates the git tag via the GitHub API and publishes the release.

## CLI Commands

The CLI is built from the changewrite repo itself via `lute run build` and invoked internally by the Action. It is also available as a standalone binary via Rokit.

| Command      | Description                                                                                |
| ------------ | ------------------------------------------------------------------------------------------ |
| `gate`       | Checks whether the configured version already has a tag; outputs release state as JSON     |
| `draft`      | Creates a draft GitHub release for the current version                                     |
| `publish`    | Publishes a draft release                                                                  |
| `prepare-pr` | Collects `.changes/` entries, bumps version, updates `CHANGELOG.md`, returns changed files |
| `bump`       | Bumps to a specific version, an escape hatch for burned or skipped tags                    |
| `notes`      | Renders release notes for a given version                                                  |
| `attach`     | Attaches build artifacts to a draft release                                                |

## GitHub Action

```yaml
- uses: flipbook-labs/changewrite@v0.3.0
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    pr-token: ${{ secrets.APP_TOKEN }} # Pass a PAT/app token so the PR triggers other workflows
    bump: minor # Which semver component to bump (major, minor, patch); default: minor
```

Key inputs: `bump`, `publish-immediately`, `force-version` (pin an exact version, useful to recover from a burned tag), `post-draft-hook` and `post-publish-hook` (bash run after draft/publish, used to attach artifacts or trigger downstream work).

Key outputs: `should_publish`, `has_changes`, `version`, `tag`, `draft_created`, `release_created`.

## Configuration

`changewrite.toml` lives at the repo root:

```toml
[version]
current = "0.3.0"
mirror = [
  { file = "loom.config.luau" },  # Other files to keep in sync with the version
]
```

The `mirror` list tells changewrite which files to patch with the new version string when it bumps `current`.

## Status

Live at [flipbook-labs/changewrite](https://github.com/flipbook-labs/changewrite), currently v0.3.0. Used by the flipbook-labs org repos. The flipbook plugin repo itself still uses a manual GitHub release workflow and has not yet adopted changewrite.

> [!seealso]
> [[contributing/creating-releases|Creating Releases]]: the current manual release process for the flipbook plugin
