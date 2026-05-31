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

Prefer the direct overlay into Flipbook unless the task specifically needs to verify Storyteller's vendored ModuleLoader copy.

```bash
# from module-loader repo
lute run try-in-flipbook
```

If Storyteller also needs the local ModuleLoader bundle:

```bash
# from module-loader repo
lute run try-in-storyteller

# from storyteller repo
lute run try-in-flipbook
```

After either route, rebuild Flipbook:

```bash
# from flipbook repo
lute run build plugin --channel dev --clean
```

## Requirements

- `flipbook`, `storyteller`, and `module-loader` should be sibling checkouts.
- The target repo must have had `lute run install` run so `Packages/_Index` contains the installed package.
- The `try-in-*` scripts build dependency `dist/` output and overlay it into the sibling repo's Wally package install.
