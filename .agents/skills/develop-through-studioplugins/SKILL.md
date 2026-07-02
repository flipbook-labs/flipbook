---
name: develop-through-studioplugins
description: "Special workflow for testing FlipbookCore changes through the StudioPlugins Flipbook plugin. Use only when: the engineer explicitly asks to verify changes through StudioPlugins, mentions StudioPlugins with local FlipbookCore rotriever builds, or says the StudioPlugins watcher is already running."
type: process
---

# Develop Through StudioPlugins

This workflow tests FlipbookCore changes in the StudioPlugins Flipbook plugin. Use only when the engineer explicitly requests it; default development path is `flipbook-build-and-toolchain` with roblox target.

## When not to use

For standard Flipbook plugin development, see `flipbook-build-and-toolchain`. For testing dependency changes (storyteller, module-loader) in isolation, see `test-dependencies-in-flipbook`.

## Setup (Engineer to Complete Once)

1. Build FlipbookCore rotriever target in the `flipbook` repo:

```bash
lute run build --target rotriever --clean
```

Output: `build/flipbook-core-rotriever/`.

2. In the StudioPlugins repo's Flipbook Rotriever manifest (ask engineer for its location and build command), configure `FlipbookCore` to use the local build:

```toml
[dependencies]
FlipbookCore = { path = "/path/to/flipbook/build/flipbook-core-rotriever" }
```

3. Build the StudioPlugins Flipbook plugin using the engineer's build command. Studio should have an active watcher.

## Agent-Run Loop

For each iteration:

1. Rebuild FlipbookCore from the `flipbook` repo:

```bash
lute run build --target rotriever --clean
```

2. Rebuild the StudioPlugins Flipbook plugin. Ask the engineer for the exact build command if unknown.

3. Studio's watcher reloads the plugin automatically.

## Dependency Overlays (If Needed)

Only run these if the current task changed `storyteller` or `module-loader`:

```bash
# from module-loader repo, if task changed it
lute run try-in-flipbook

# from storyteller repo, if task changed it
lute run try-in-flipbook
```

When StudioPlugins is configured to use the local rotriever output, its watcher picks up the rebuilt bundle automatically. Do not ask the engineer to run FlipbookCore rebuild manually; the agent runs it unless the command fails and needs human debugging.

---

## Provenance and Maintenance

**Date stamped:** as of 2026-07-02.

**Re-verify these claims when this skill next loads** (run from the `flipbook/` repo root):
- Build targets and flags: run `grep -A 1 'target.*roblox.*rotriever' .lute/build.luau`
- Output path for rotriever: run `grep -n "flipbook-core-rotriever\|build/.*rotriever" .lute/build.luau`
- Plugin build command exists: ask engineer to confirm StudioPlugins build command and watcher are documented
