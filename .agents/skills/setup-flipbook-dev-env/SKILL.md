---
name: setup-flipbook-dev-env
description: "Set up or repair the Flipbook, Storyteller, or ModuleLoader development environment. Use when: first-time setup, installing dependencies, managing .env files, troubleshooting rokit/wally/lute, or repairing stale tooling in the Flipbook repo family."
type: process
---

# Setup Flipbook Dev Environment

First-time setup or when package/tooling state looks stale. Rokit installs tools; Wally installs packages; Lute runs builds and tests.

## When not to use

For testing local dependency changes (storyteller or module-loader), see `test-dependencies-in-flipbook`. For running lint/analyze/test tasks, see `run-flipbook-checks`. For toolchain details, see `flipbook-build-and-toolchain`.

## Repo Family Layout

`flipbook`, `storyteller`, and `module-loader` are expected to be sibling checkouts:
```bash
~/git/flipbook
~/git/storyteller
~/git/module-loader
```

The install script detects and works with any repo in this family.

## Standard Setup

Run these commands from the repo root:

```bash
rokit install
lute run install
```

For `flipbook` only, ensure a `.env` file exists:

```bash
cp .env.template .env
```

**Required:** `BASE_URL` in `.env` must be set to `https://apis.flipbooklabs.com` (the default in `.env.template`). The build task checks for this value (anchor: `if not process.env.BASE_URL` in `.lute/build.luau`).

## What `lute run install` Does

- Installs Wally runtime packages into `Packages/`.
- Installs Lute tooling packages and moves them to `LuauPackages/`.
- Generates Rojo sourcemaps.
- Applies package patches needed by Flipbook.

## Common Troubleshooting

**"Cannot resolve packages"** — `lute run` tasks failing with unresolved imports: run `lute run install` again.

**Stale build output after dependency changes** — Use `lute run build --clean` for a full rebuild from scratch.

**"ERROR No such file or directory (os error 2)"** — Rokit is trying to invoke a tool it has not installed. Run `rokit install` to recover.

**Do not edit `Packages/` or `LuauPackages/` directly** — these are generated. Regenerate with `lute run install` if needed.

---

## Provenance and Maintenance

**Date stamped:** as of 2026-07-02.

**Re-verify these claims when this skill next loads:**
- `rokit.toml` presence and tool list: run `cat rokit.toml | grep "^\["` to confirm tools section exists
- `.env.template` contents: run `grep BASE_URL .env.template` to confirm default is `https://apis.flipbooklabs.com`
- BASE_URL guard in build: run `grep -n "if not process.env.BASE_URL" .lute/build.luau` to verify anchor exists
- `lute run install` availability: run `lute run install --help` from repo root
