# Flipbook - Agent Instructions

## Repo Overview

Flipbook is a Roblox Studio plugin for browsing and testing UI stories. The dependency chain is:

```
Flipbook  ←  Storyteller  ←  ModuleLoader
```

All three repos (`flipbook`, `storyteller`, `module-loader`) use the same toolchain and conventions, and are expected to be checked out as siblings on disk under `/Users/dminnerly/git/`.

---

## Tech Stack

| Tool | Role |
| --- | --- |
| **Lute** | Task runner for all scripts (`lute run <script>`) |
| **Rokit** | Toolchain version manager (`rokit install` pins tools from `rokit.toml`) |
| **Wally** | Roblox package manager (Roblox runtime deps) |
| **Loom** | Luau package manager for tooling/scripts (installs to `LuauPackages/`) |
| **Rojo** | Syncs Luau source trees to Roblox place format; used for sourcemaps and builds |
| **Darklua** | Transforms Luau-style `require` paths to Roblox `require()` calls during build |
| **Rocale** | Roblox Open Cloud CLI; uploads and runs test places in the cloud |
| **Jest** (jsdotlua) | Unit test framework; tests run inside a Roblox place via Rocale |
| **Selene** | Luau linter |
| **StyLua** | Luau formatter |
| **React** (17, jsdotlua) | UI framework used throughout Flipbook and Storyteller |
| **Charm** | Reactive signals library; used for stores in both Flipbook and Storyteller |
| **ModuleLoader** | Bypasses Roblox's require cache; core to how Flipbook reloads stories |
| **Storyteller** | Story discovery, loading, and rendering; wraps ModuleLoader |

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

### Full script inventory

| Script | Repos | What it does |
| --- | --- | --- |
| `lute run install` | all | Installs Wally deps, Loom tooling, generates sourcemaps, patches packages |
| `lute run build` | all | Compiles source → build output; see flags below |
| `lute run test` | all | Builds (dev channel) then runs Jest tests inside a Roblox place via Rocale |
| `lute run lint` | all | Runs Selene + StyLua `--check`; fails on any `.lua` files (must be `.luau`) |
| `lute run analyze` | all | Runs `luau-lsp` type analysis; run `lute setup` first if running locally |
| `lute run clean` | flipbook | Removes `build/`, Studio plugin `.rbxm`, and root `Flipbook.rbxm` |
| `lute run bump-version` | flipbook | Bumps version in `wally.toml`, `loom.config.luau`, and `workspace/flipbook-core/rotriever.toml` |
| `lute run serve-docs` | all | `npm install` + `npm start` in `docs/` (local Docusaurus server) |
| `lute run try-in-flipbook` | storyteller, module-loader | Builds and overlays `dist/` into the sibling `flipbook` repo's Wally install |
| `lute run try-in-storyteller` | module-loader | Builds and overlays `dist/` into the sibling `storyteller` repo's Wally install |

### Setup (first time or after toolchain changes)

```bash
rokit install        # Install pinned tool versions from rokit.toml
lute run install     # Install Wally deps, Loom deps, generate sourcemaps, patch packages
cp .env.template .env  # Flipbook only; set BASE_URL at minimum for builds
```

### Building

```bash
# Flipbook — build dev plugin to Studio plugins folder
lute run build plugin --channel dev

# Flipbook — full rebuild (use after dependency changes)
lute run build plugin --channel dev --clean

# Flipbook — watch mode (incremental on workspace member changes)
lute run build plugin --channel dev --watch

# Flipbook — build FlipbookCore as a rotriever bundle (for Studio-internal Flipbook)
lute run build --target rotriever --clean

# Storyteller / ModuleLoader — build dist/ bundle
lute run build --channel dev
lute run build --channel prod
```

**`--channel dev` vs `--channel prod`:** Dev builds retain `*.spec.luau`, `*.story.luau`, `*.storybook.luau`, and `jest.config.luau`. Prod builds prune them. For Flipbook, `PROD_CONFIG.prunedDirs` also strips `code-samples`, `example`, `template`, and `test-runner` from the plugin.

**`--clean`:** Forces a full rebuild, bypassing the incremental build cache at `build/build-cache.json`.

### Testing

Tests run inside a Roblox place via Rocale (Open Cloud). A `ROBLOX_API_KEY` is required.

```bash
lute run test                            # Run all tests
lute run test --filter "SomePattern"     # Filter by test path pattern
lute run test --apiKey "YOUR_KEY"        # Pass API key directly instead of env var
```

### Quality checks

```bash
lute run lint       # selene + stylua --check; also fails on any .lua files (use .luau)
lute run analyze    # luau-lsp analysis; run lute setup first if running locally
```

---

## Code Style and Conventions

- **File extension:** All Luau files must use **`.luau`**, never `.lua`. The linter will fail if any `.lua` files are found.
- **Formatter:** StyLua with `sort_requires = true`. Run `stylua <file>` or `lute run lint` will check.
- **Linter:** Selene with `std = "roblox"` and `global_usage = "allow"`.
- **Test files:** `*.spec.luau` colocated with source files. Jest config uses `testMatch = { "**/*.spec" }`.
- **Imports:** In source, use Luau-style path aliases (`@pkg/Charm`, `@workspace/flipbook-core/src`, etc.); Darklua converts these to Roblox `require()` during build.
- **No `.lua` files:** Strictly `.luau`. The lint script explicitly errors on any `.lua` extension found.

---

## Environment Setup (Flipbook)

Copy `.env.template` to `.env` before running any build. Required variables:

| Variable | Required for | Notes |
| --- | --- | --- |
| `BASE_URL` | All builds | Hard error if unset. Default: `https://apis.flipbooklabs.com` |
| `LOG_LEVEL` | Runtime | Default: `info` |
| `ENABLE_OUTPUT_LOGGING` | Runtime | Default: `false` |
| `ROBLOX_API_KEY` | Tests | Rocale Open Cloud key |
| `ROBLOX_UNIT_TESTING_PLACE_ID` | Tests | Pre-filled in template |
| `ROBLOX_UNIT_TESTING_UNIVERSE_ID` | Tests | Pre-filled in template |

`BASE_URL` and `LOG_LEVEL` are injected into the plugin at build time via Darklua's `_G` global injection.

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

## Workflow 1: Testing Changes from Dependencies in Flipbook

Use this when making changes to `storyteller` or `module-loader` and wanting to verify them inside Flipbook.

Each dependency repo has a `lute run try-in-flipbook` script that builds the dependency and overlays it onto Flipbook's Wally package install. ModuleLoader additionally has `lute run try-in-storyteller` for overlaying into Storyteller's install.

### Changed Storyteller → Try in Flipbook

From the `storyteller` repo:

```bash
lute run try-in-flipbook
```

This builds Storyteller and replaces the `dist/` bundle inside `flipbook/Packages/_Index/<storyteller-pkg>/dist/`.

Then from the `flipbook` repo:

```bash
lute run build plugin --channel dev --clean
```

### Changed ModuleLoader → Try in Flipbook

**Option A — Push ModuleLoader directly into Flipbook:**

From the `module-loader` repo:

```bash
lute run try-in-flipbook
```

**Option B — Push ModuleLoader into Storyteller first, then Storyteller into Flipbook:**

```bash
# from module-loader repo
lute run try-in-storyteller

# from storyteller repo
lute run try-in-flipbook
```

After either option, rebuild Flipbook:

```bash
# from flipbook repo
lute run build plugin --channel dev --clean
```

### Requirements

- Repos must be checked out as siblings: `../storyteller` and `../module-loader` must exist relative to `../flipbook`.
- The target repo (`flipbook` or `storyteller`) must have had `lute run install` run so `Packages/_Index` contains the installed package.
- The `try-in-*` scripts default to a **prod** build (specs stripped). If you need specs in the overlay, run `lute run build --channel dev` manually in the dependency repo first, then run the try-in script (it will rebuild with the default channel again — to avoid this, edit the overlay destination manually or temporarily patch the script).

---

## Workflow 2: Developing Flipbook Internal (ships with Roblox Studio)

Flipbook Internal is the Studio-bundled version, in `studio-plugins` under `Standalone/Flipbook/`. It consumes `FlipbookCore` from the base `flipbook` repo as a Rotriever path dependency.

### Setup Steps

**1. Build FlipbookCore from the flipbook repo:**

```bash
# from ~/git/flipbook
lute run build --target rotriever --clean
```

Outputs to `build/flipbook-core-rotriever/`.

**2. Point studio-plugins at your local build:**

In `Standalone/Flipbook/rotriever.toml` (studio-plugins repo), set:

```toml
[dependencies]
FlipbookCore = { path = "/path/to/flipbook/build/flipbook-core-rotriever" }
```

Use the absolute path matching your local `flipbook` checkout.

**3. Build and watch Flipbook Internal:**

```bash
# from the studio-plugins repo
gobot plugin build Flipbook --prod --watch
```

**4. Enable the feature flag in Studio:** flip `FFlagEnableFlipbook2`.

**5. Open a place in Studio that has stories.**

### Making Iterative Changes

- **Changes to flipbook source:** re-run `lute run build --target rotriever --clean` in the flipbook repo, then let the `gobot` watcher pick up the updated rotriever output.
- **Changes directly to `Standalone/Flipbook/src`:** picked up automatically by `--watch`.
