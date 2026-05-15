---
name: develop-through-studioplugins
description: Special internal workflow for testing FlipbookCore changes through the StudioPlugins Flipbook plugin. Use only when the engineer explicitly asks to verify Flipbook through StudioPlugins, mentions StudioPlugins with FlipbookCore local rotriever builds, or says the StudioPlugins Flipbook watcher is already running.
---

# Develop Through StudioPlugins

This is a special internal workflow for testing this repo's `FlipbookCore` changes through the StudioPlugins repo. Do not use it as the default Flipbook development path.

## Setup

1. Build FlipbookCore from the `flipbook` repo:

```bash
lute run build --target rotriever --clean
```

The output path is `build/flipbook-core-rotriever/`.

2. In the StudioPlugins repo's Flipbook Rotriever manifest, point `FlipbookCore` at the local build output:

```toml
[dependencies]
FlipbookCore = { path = "/path/to/flipbook/build/flipbook-core-rotriever" }
```

3. Build and watch the StudioPlugins Flipbook plugin using the StudioPlugins repo's local development docs or agent instructions. Keep Studio open while iterating.

## Agent-Run Loop

Use this loop when the engineer already has Studio open and StudioPlugins is already watching the Flipbook plugin.

By default, only rebuild FlipbookCore:

```bash
cd ~/git/flipbook
lute run build --target rotriever --clean
```

`lute run build --target rotriever --clean --watch` may also work for a long-running local loop, but agents should prefer the one-shot rebuild and re-run it after changes unless the engineer specifically asks for watch mode.

## Dependency Changes

Only run these overlay steps when the current task actually changed that dependency repo:

```bash
# if this task changed module-loader
cd ~/git/module-loader
lute run try-in-flipbook

# if this task changed storyteller
cd ~/git/storyteller
lute run try-in-flipbook
```

When StudioPlugins points `FlipbookCore` at the local rotriever output, its watcher should pick up the rebuilt bundle automatically. Do not ask the engineer to run the FlipbookCore rebuild manually; run it from the agent unless the command fails and needs human intervention.
