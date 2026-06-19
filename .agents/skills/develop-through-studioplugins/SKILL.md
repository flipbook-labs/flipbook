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

3. Build the StudioPlugins Flipbook plugin.

## Agent-Run Loop

For each iteration:

1. The agent rebuilds FlipbookCore. From the `flipbook` repo:

```bash
lute run build --target rotriever --clean
```

2. The agent rebuilds the StudioPlugins Flipbook plugin using the engineer's documented build command for that repo. Ask the engineer for the exact command if it cannot be determined.

Studio will reload the plugin automatically once the build completes.

## Dependency Changes

Only run these overlay steps when the current task actually changed that dependency repo:

```bash
# from the module-loader repo, if this task changed it
lute run try-in-flipbook

# from the storyteller repo, if this task changed it
lute run try-in-flipbook
```

When StudioPlugins points `FlipbookCore` at the local rotriever output, its watcher should pick up the rebuilt bundle automatically. Do not ask the engineer to run the FlipbookCore rebuild manually; run it from the agent unless the command fails and needs human intervention.
