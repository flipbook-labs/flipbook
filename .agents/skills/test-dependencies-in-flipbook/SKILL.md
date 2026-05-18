---
name: test-dependencies-in-flipbook
description: Verify local Storyteller or ModuleLoader changes inside Flipbook by overlaying dependency builds. Use when changing storyteller, module-loader, ModuleLoader, Storyteller, try-in-flipbook, try-in-storyteller, or when the user asks to test dependency changes in Flipbook.
---

# Test Dependencies In Flipbook

Use this only when the current task changed `storyteller` or `module-loader`, or when the engineer explicitly asks to verify dependency changes through Flipbook. Do not run dependency overlay scripts as routine setup.

## Why This Exists

Wally only resolves packages from the registry; it does not support local path dependencies, git dependencies, or temporary workspace overrides. To test local `storyteller` or `module-loader` changes inside Flipbook, build the dependency and overlay its `dist/` output into Flipbook's installed Wally package directory. This is a workaround until Lute's package manager can support a cleaner local dependency workflow.

## Changed Storyteller

From the `storyteller` repo:

```bash
lute run try-in-flipbook
```

This builds Storyteller and replaces the `dist/` bundle inside `flipbook/Packages/_Index/<storyteller-pkg>/dist/`.

Then from the `flipbook` repo:

```bash
lute run build plugin --channel dev --clean
```

## Changed ModuleLoader

Storyteller vendors its own `module-loader` tree, and Flipbook also depends on `module-loader` directly. For a complete verification chain, run all of the following (sibling checkouts), in order:

```bash
# 1. Overlay module-loader into Storyteller's vendored copy
cd ~/git/module-loader && lute run try-in-storyteller

# 2. Build Storyteller and overlay its dist/ into Flipbook (includes that vendored ModuleLoader)
cd ~/git/storyteller && lute run try-in-flipbook

# 3. Overlay module-loader into Flipbook's direct Wally install
cd ~/git/module-loader && lute run try-in-flipbook

# 4. Produce the FlipbookCore bundle consumed by StudioPlugins Rotriever
cd ~/git/flipbook && lute run build --target rotriever --clean
```

`lute run build plugin --channel dev --clean` rebuilds the dev Studio plugin and is the usual loop for dogfooding in Flipbook itself. The **rotriever** build step is separate: it is what you need after dependency overlays when verifying through **StudioPlugins** (point `FlipbookCore` at `build/flipbook-core-rotriever/` in the plugin manifest).

## Requirements

- `flipbook`, `storyteller`, and `module-loader` should be sibling checkouts.
- The target repo must have had `lute run install` run so `Packages/_Index` contains the installed package.
- The `try-in-*` scripts build dependency `dist/` output and overlay it into the sibling repo's Wally package install.
