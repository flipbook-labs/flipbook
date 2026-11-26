---
name: release
description: "How Flipbook releases happen, what an agent must not do in the release flow, which environments and secrets gate CI, and the rules for changes that touch telemetry, community parity, or dependencies. Use when: preparing or reviewing a change that affects releases, publishing, CI workflows, Creator Store assets, storybook previews, PostHog release reporting, telemetry, or dependency bumps."
---

# Release

`AGENTS.md` and `.github/MERGE_POLICY.md` cover review ownership, Greptile, and the PR template. This skill covers what they do not: how a release happens, how CI is gated, and the rules for risky kinds of change. Read the workflow files in `.github/workflows/` for exact triggers and steps. This skill only records what the YAML does not explain.

## How a release happens

Every release-worthy change adds one entry under `.changes/`. The format is in `.changes/README.md`. Every push to `main` runs `release.yml`, which builds `Flipbook.rbxm` and runs Changewrite. Changewrite opens or updates a `Publish v{version}` pull request that bumps the version, mirrors it into the manifests listed in `changewrite.luau`, and writes `CHANGELOG.md`.

A person merges that publish pull request. Merging it creates the tag and the GitHub release with `Flipbook.rbxm` attached. The published release triggers a second `release.yml` run that publishes to the Creator Store.

Never push or create a tag, edit a mirrored version string, or edit `CHANGELOG.md` by hand. Never merge the publish pull request yourself. The `force-version` input on `release.yml` exists only to recover from a version or tag that cannot be published, and a person runs it.

To exercise the release path from an ordinary pull request, apply the `debug:release-pr` label. Changewrite then prepares a release on a separate debug branch and publishes nothing.

## Channels and assets

The `beta` channel publishes to the dev asset on purpose. Nightly builds from `main` use `--channel beta` and land on the Flipbook (Dev) asset. Do not add a separate beta asset or "fix" the mapping. `ASSET_NAMES_BY_CHANNEL` in `.lute/lib/creator-store/assets.luau` is the source of truth, and the same file defines the assets and their IDs.

The smoketest has its own asset, `smoketest`, selected by the `--smoketest` flag rather than by channel. `strict.yml` builds a prod plugin on a secretless runner, then publishes it to the smoketest asset from the gated job. A smoketest failure means the Creator Store rejected the build or the asset is misconfigured. It does not mean the tests failed.

`lute run publish-plugin` only uploads a built `.rbxm`, so each publish job builds or downloads `Flipbook.rbxm` first. The Open Cloud Assets API rejects plugin uploads made with an API key, so the script uploads through a Luau Execution task that calls `AssetService:CreateAssetVersionAsync`. That task is `.lute/tasks/publish-plugin.luau`.

## Environments and secrets

Secrets live in GitHub environments, never in workflow-level `env`. Environment names are not obvious from the code, so use these:

- `luau-execution` and `luau-execution-gated`: run the cloud tests and the smoketest publish, using `ROBLOX_API_KEY`. Pull requests from forks get the `-gated` environment, which needs a maintainer's approval before any secret is exposed. Same-repository pull requests use the ungated one.
- `roblox-creator-store`: the prod publish, using `ROBLOX_API_KEY`.
- `roblox-creator-store-dev`: the nightly publish to the dev asset.
- `storybook-preview`: storybook deploys, using a separate key, `ROBLOX_STORYBOOK_PREVIEW_API_KEY`.
- `posthog`: release-health reporting, using `OP_SERVICE_ACCOUNT_TOKEN`.

The release job signs in as the `flipbook-backend` GitHub App through the `FLIPBOOK_BACKEND_CLIENT_ID` variable and the `FLIPBOOK_BACKEND_APP_PRIVATE_KEY` secret. It does not use `GITHUB_TOKEN` because events created by that token do not trigger the release-published run.

The `strict.yml` and `storybook.yml` workflows use `pull_request_target`. Pull request code is built on a secretless runner, and only the built artifacts reach jobs that hold secrets. Keep it that way. Never check out or run pull request code in a job that has an environment secret. Environment approval only delays when a protected job starts. It does not make fork code safe to run with that job's secrets.

Fork and Dependabot builds skip build provenance attestation in `ci.yml`, because their read-only token cannot mint attestations. The build and artifact upload still run.

## Storybook previews

A pull request storybook deliberately uses the last public Flipbook release as its runtime, so a UI change is previewed against the shipped baseline and a half-built plugin cannot hide it. On `main`, the workflow embeds a fresh prod build instead, which catches embedding problems before a release. Do not pass `flipbook-rbxm` for pull request deploys. On `pull_request_target` runs, deploy-storybook's own comment is turned off because v0.4.1 still only comments on `pull_request` events. The deploy job posts the preview link with `flipbook-cli comment` instead.

## PostHog release reporting

Release jobs report to PostHog after the fact: pending changes on each push to `main`, beta publishes, and prod releases. These jobs use `continue-on-error`, so a reporting failure never blocks a release. The credentials live in 1Password and are resolved with `op run`. The `PostHog Check` workflow validates them weekly and can be dispatched on demand after rotating a credential. A failing check means the credential needs replacing, not that the release is broken. The commands are in `.lute/posthog.luau`, and `lute run posthog --dry-run` sends nothing.

## Rules for risky changes

Community first. Flipbook may run inside internal Roblox environments, but the internal build must not gain features that the community build cannot have. If a feature needs an internal-only API, do not ship it here. Raise it as future work.

Telemetry. Collection is opt-in. The telemetry client's `capture` sends nothing unless consent is `Granted`. Any change that adds events, fields, or a new kind of collection must stay behind that consent and must say in the pull request what is collected, why, and how it respects privacy. Do not add collection that bypasses `capture`.

Dependency bumps. After changing `wally.toml`, `pkg.luau`, `rokit.toml`, or `RobloxPackages`, rebuild with `--clean` before you trust any result, because a cached build can hide a broken require. For Storyteller or ModuleLoader changes, verify through Flipbook with the overlay described in [`dev-env`](../dev-env/SKILL.md) before relying on a release of the dependency. Confirm the overlay is the code that ran. Do not bump tool versions as a side effect of another change.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
ls .github/workflows/release.yml .github/workflows/storybook.yml .github/workflows/strict.yml
git grep -n ASSET_NAMES_BY_CHANNEL -- .lute/lib/creator-store/assets.luau
git grep -n CreateAssetVersionAsync -- .lute/tasks/publish-plugin.luau
git grep -n luau-execution-gated -- .github/workflows
git grep -n "flipbook-cli comment" -- .github/workflows/storybook.yml
ls .lute/posthog.luau
```
