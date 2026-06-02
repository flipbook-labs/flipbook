# Flipbook - Agent Instructions

## Repo Overview

Flipbook is a Roblox Studio plugin for browsing and testing UI stories. The dependency chain is:

```
Flipbook  ←  Storyteller  ←  ModuleLoader
```

All three repos (`flipbook`, `storyteller`, `module-loader`) use the same toolchain and conventions, and are expected to be checked out as siblings on disk (e.g. `~/git/flipbook`, `~/git/storyteller`, `~/git/module-loader`).

---

## Tech Stack

| Tool                     | Role                                                                           |
| ------------------------ | ------------------------------------------------------------------------------ |
| **Lute**                 | Task runner for all scripts (`lute run <script>`)                              |
| **Rokit**                | Toolchain version manager (`rokit install` pins tools from `rokit.toml`)       |
| **Wally**                | Roblox package manager (Roblox runtime deps)                                   |
| **Loom**                 | Luau package manager for tooling/scripts (installs to `LuauPackages/`)         |
| **Rojo**                 | Syncs Luau source trees to Roblox place format; used for sourcemaps and builds |
| **Darklua**              | Transforms Luau-style `require` paths to Roblox `require()` calls during build |
| **Rocale**               | Roblox Open Cloud CLI; uploads and runs test places in the cloud               |
| **Jest** (jsdotlua)      | Unit test framework; tests run inside a Roblox place via Rocale                |
| **Selene**               | Luau linter                                                                    |
| **StyLua**               | Luau formatter                                                                 |
| **React** (17, jsdotlua) | UI framework used throughout Flipbook and Storyteller                          |
| **Charm**                | Reactive signals library; used for stores in both Flipbook and Storyteller     |
| **ModuleLoader**         | Bypasses Roblox's require cache; core to how Flipbook reloads stories          |
| **Storyteller**          | Story discovery, loading, and rendering; wraps ModuleLoader                    |

---

## Repository Layout

### Flipbook

```
flipbook/
├── src/                    # Thin plugin entry point (Studio bootstrap only)
├── workspace/              # Real application code, organized as workspace members:
│   ├── flipbook-core/      # Main library — React app, story browser, telemetry, settings
│   ├── flipbook-next/      # Experimental next-gen package
│   ├── test-runner/        # Runs Jest.runCLI against flipbook-core tests
│   ├── example/            # Dogfood stories/components
│   ├── code-samples/       # Sample stories for Roact, Fusion, React+Storyteller
│   └── template/           # Scaffold for new workspace members
├── build/                  # Build output (gitignored):
│   ├── dev/roblox/         # Dev plugin build
│   ├── prod/roblox/        # Production build
│   └── flipbook-core-rotriever/  # Rotriever bundle for Studio-internal Flipbook
├── .lute/                  # Lute task scripts
├── Packages/               # Wally installs (gitignored)
├── LuauPackages/           # Loom/Lute tooling packages (moved from Packages/ on install)
├── RobloxPackages/         # roblox-packages CLI installs (Foundation, Promise, Dash, etc.)
├── project.luau            # Shared path constants used by all Lute scripts
├── wally.toml              # Roblox runtime dependencies
├── loom.config.luau        # Loom manifest (Lute, flipbook-batteries, dotenv)
└── .env / .env.template    # Environment variables (copy template to .env)
```

Most application code lives under `workspace/flipbook-core/src/`, not `src/`. The root `src/init.server.luau` is only a thin bootstrap that calls `FlipbookCore.createFlipbookPlugin(...)`.

### Storyteller / ModuleLoader

Both follow a simpler layout:

```
<repo>/
├── src/                    # Authoring source
├── dist/                   # Build output (gitignored) — what Wally ships
├── .lute/                  # Lute task scripts
├── Packages/               # Wally installs
├── LuauPackages/           # Loom tooling packages
├── project.luau            # Shared path constants
├── wally.toml              # Package metadata + dependencies
└── loom.config.luau        # Loom manifest
```

Build output (`dist/`) is a Darklua-processed mirror of `src/` with Luau-style requires converted to Roblox `require()` calls. **Wally publishes from `dist/`**, not `src/`.

---

## Scripts (`lute run`)

Lute is the task runner for all three repos — the Luau equivalent of `npm run`. **Before reaching for any external tool or shell command, check whether a `lute run` script already covers it.** All scripts live in `.lute/<name>.luau` and are invoked as `lute run <name>`.

### API Keys

`.env` is not sourced automatically. Run `source .env` before any `lute run` command that reads from it:

```bash
source .env && lute run <command>
```

Commands that require this: `lute run test`, `lute run deploy-storybook`, `lute run upload-storybook-runtime`.

### Common Commands

```bash
# Flipbook — build dev plugin to Studio plugins folder
lute run build plugin --channel dev

# Flipbook — full rebuild (use after dependency changes)
lute run build plugin --channel dev --clean

# Flipbook — watch mode (incremental on workspace member changes)
lute run build plugin --channel dev --watch

# Flipbook — build FlipbookCore as a rotriever bundle for local integration flows
lute run build --target rotriever --clean

# Storyteller / ModuleLoader — build dist/ bundle
lute run build --channel dev
lute run build --channel prod

# Validation
lute run lint
lute run analyze
lute run test
```

Use `--clean` after dependency changes or when build output appears stale. `--channel dev` retains tests and stories; `--channel prod` prunes development files.

---

## Code Style and Conventions

- **File extension:** All Luau files must use **`.luau`**, never `.lua`. The linter will fail if any `.lua` files are found.
- **Luau formatter:** StyLua with `sort_requires = true`. Run `stylua <file>` or `lute run lint` will check.
- **Luau linter:** Selene with `std = "roblox"` and `global_usage = "allow"`.
- **Markdown formatter:** Prettier. Run `lute run lint` to check; run `npx --yes prettier --write "**/*.md"` to auto-fix.
- **Test files:** `*.spec.luau` colocated with source files. Jest config uses `testMatch = { "**/*.spec" }`.
- **Imports:** In source, use Luau-style path aliases (`@pkg/Charm`, `@workspace/flipbook-core/src`, etc.); Darklua converts these to Roblox `require()` during build.

---

## Architecture Notes

### FlipbookCore vs the plugin shell

- `src/init.server.luau` is minimal: it guards against non-edit mode, sets `_G.__DEV__` in dev builds, and delegates to `FlipbookCore.createFlipbookPlugin(plugin, widget, button)`.
- All real functionality is in `workspace/flipbook-core/src/`. When working on Flipbook features, start there, not in `src/`.

### Charm flags workaround

`src/init.server.luau` sets `Charm.flags.frozen = false`. This is a documented workaround for a Storyteller issue (issue #100). Do not remove it.

### Workspace members and production pruning

The `workspace/` directory is a monorepo-style structure. Each member has its own `src/` and sometimes `rotriever.toml`. When adding a new workspace member that should not ship in the production plugin, add it to `PROD_CONFIG.prunedDirs` in `project.luau`.

### Wally vs Loom packages

- **Wally** (`Packages/`) installs Roblox runtime deps (React, Charm, Storyteller, ModuleLoader, etc.)
- **Loom** (`LuauPackages/`) installs tooling packages used by `.lute/` scripts (Lute batteries, flipbook-batteries, dotenv)
- The install script moves Loom packages out of `Packages/` into `LuauPackages/` to prevent Wally from seeing them as game deps

### Darklua and require paths

Source files use Luau-style aliases (`@pkg/`, `@workspace/`, `@repo/`, etc.). Darklua processes `src/` → `build/<channel>/<target>/` (or `dist/` in Storyteller/ModuleLoader) converting these to Roblox `require(script.X)` using Rojo sourcemaps. **Never edit files in `build/` or `dist/` directly.**

---

## Project Skills

Skill files live under `.agents/skills/<name>/SKILL.md`. Use them for conditional workflows instead of keeping all details in always-loaded context:

- `setup-flipbook-dev-env` — first-time setup, stale packages, `.env`, Wally/Loom/Rokit issues.
- `run-flipbook-checks` — lint, analyze, and Rocale-backed Jest tests.
- `test-dependencies-in-flipbook` — verifying local `storyteller` or `module-loader` changes inside Flipbook.
- `develop-through-studioplugins` — special internal StudioPlugins workflow for explicitly requested FlipbookCore verification.
