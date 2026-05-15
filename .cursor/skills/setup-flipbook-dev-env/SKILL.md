---
name: setup-flipbook-dev-env
description: Set up or repair the local Flipbook, Storyteller, or ModuleLoader development environment. Use when the user mentions setup, install, rokit, wally, loom, .env, packages, first-time setup, missing dependencies, or environment variables in the Flipbook repo family.
---

# Setup Flipbook Dev Environment

Use this for first-time setup or when package/tooling state looks stale.

## Repo Family

`flipbook`, `storyteller`, and `module-loader` are expected to be sibling checkouts, for example:

```bash
~/git/flipbook
~/git/storyteller
~/git/module-loader
```

## Standard Setup

Run these from the repo you are working in:

```bash
rokit install
lute run install
```

For `flipbook`, also make sure a `.env` exists:

```bash
cp .env.template .env
```

`BASE_URL` is required for builds. The default expected value is `https://apis.flipbooklabs.com`.

## What Install Does

- Installs Wally runtime packages into `Packages/`.
- Installs Loom/Lute tooling packages and moves them to `LuauPackages/`.
- Generates sourcemaps.
- Applies package patches needed by Flipbook.

## Common Checks

- If a `lute run` task cannot resolve packages, run `lute run install` again.
- If build output seems stale after dependency changes, use a clean build.
- Do not edit generated package output directly; regenerate it from source.
