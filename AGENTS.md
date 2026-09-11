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
├── LuauPackages/           # rbxasset only; Loom packages resolve from the store (~/.loom/store)
├── RobloxPackages/         # roblox-packages CLI installs (Foundation, Promise, Dash, etc.)
├── project.luau            # Shared path constants used by all Lute scripts
├── wally.toml              # Roblox runtime dependencies
├── loom.config.luau        # Loom manifest (Lute, flipbook-batteries, dotenv; AgentSkills dev dep)
└── .env / .env.template    # Environment variables (copy template to .env)
```

Most application code lives under `workspace/flipbook-core/src/`, not `src/`. The root `src/` directory contains only thin plugin and embedded bootstraps; `src/PluginStarterScript.plugin.luau` delegates plugin startup to `FlipbookCore.createFlipbookPlugin(...)`.

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

### Comments explain the present, not the history

A comment's job is to explain why the code is the way it is **right now** — for a reader who has never seen any previous version. Write every comment so it stands on its own against the current code.

Do **not** write comments that only make sense as a diff against a past shape. These narrate a refactor instead of the code:

- "This used to be inline; the logic now lives in X."
- "This workflow is just a thin wrapper now."
- "Where did all the release logic go? It moved to Y."
- "Previously we did A, but now we do B."

Such comments have a tiny window of relevance. After the next refactor the code has deviated again, the "previous shape" is two shapes back, and no one can verify the claim or use it — it's just litter carrying dead context forward. The old implementation is not coming back; `git log` already remembers it.

Two tests before keeping a comment:

1. **Would it make sense to someone who never saw the old code?** If it only parses as a contrast with a prior version, cut it or rewrite it to describe the present on its own terms.
2. **Is the "why" a property of the code as it stands**, or a story about how it got here? Keep the former (e.g. "Charm.flags.frozen = false works around Storyteller issue #100"). Drop the latter.

When editing or reviewing, treat surviving history-relative comments as litter to clean up, the same as dead code.

---

## Architecture Notes

### FlipbookCore vs the plugin shell

- `src/PluginStarterScript.plugin.luau` is minimal: it guards against non-edit mode, sets `_G.__DEV__` in dev builds, and delegates to `FlipbookCore.createFlipbookPlugin(plugin, widget, button)`.
- All real functionality is in `workspace/flipbook-core/src/`. When working on Flipbook features, start there, not in `src/`.

### Charm flags workaround

`src/PluginStarterScript.plugin.luau` sets `Charm.flags.frozen = false`. This is a documented workaround for a Storyteller issue (issue #100). Do not remove it.

### Workspace members and production pruning

The `workspace/` directory is a monorepo-style structure. Each member has its own `src/` and sometimes `rotriever.toml`. When adding a new workspace member that should not ship in the production plugin, add it to `PROD_CONFIG.prunedDirs` in `project.luau`.

### Wally vs Loom packages

- **Wally** (`Packages/`) installs Roblox runtime deps (React, Charm, Storyteller, ModuleLoader, etc.)
- **Loom** installs tooling packages used by `.lute/` scripts (Lute batteries, flipbook-batteries, dotenv) into the global store (`~/.loom/store`), which the `@luaupkg` alias resolves requires from directly — nothing is copied into the repo. The `AgentSkills` shared skill library is a Loom dev dependency that lands in the same store for agents to read (not required at runtime)
- `LuauPackages/` now holds only rbxasset (a Lune dependency); Wally and Loom no longer share the `Packages/` dir, so no post-install move is needed

### Darklua and require paths

Source files use Luau-style aliases (`@pkg/`, `@workspace/`, `@repo/`, etc.). Darklua processes `src/` → `build/<channel>/<target>/` (or `dist/` in Storyteller/ModuleLoader) converting these to Roblox `require(script.X)` using Rojo sourcemaps. **Never edit files in `build/` or `dist/` directly.**

---

## Shared skills: flipbook-labs/agent-skills

Cross-cutting doctrine and Flipbook-specific runbooks do not live in this repo. They live in the org's shared, versioned [AgentSkills](https://github.com/flipbook-labs/agent-skills) library, pinned as a dev dependency in [`loom.config.luau`](loom.config.luau) and installed by `lute run install` into the Loom store (`~/.loom/store`). Routing is manual and on demand: read the library's index up front, then read a skill before doing the work it covers.

Before preparing, reviewing, or merging a pull request, read [.github/MERGE_POLICY.md](.github/MERGE_POLICY.md) and the shared `flipbook-change-control` skill. Ownership is inferred from changed files. Mixed application and engine changes require application review. Repository-stewardship changes belong to `@flipbook-labs/flipbook-admins` and have no separate human-approval requirement.

Preserve `.github/pull_request_template.md` instead of replacing it with an agent-authored structure. For user-visible changes, include visual evidence that lets the application reviewer evaluate the result.

Greptile must treat this file, `.github/MERGE_POLICY.md`, and the relevant shared skills as authoritative repository guidance. The repositories listed in `.greptile/config.json` provide shared conventions and cross-repository implementation context. Keep `.greptile/files.json` limited to stable initial context, then follow this index and the changed code into specialized skills. When sources conflict, prefer this repository and then the shared skills. Assess implementation safety independently from merge authorization: a change requiring human application approval is not inherently lower quality.

Greptile findings must be evaluated rather than accepted mechanically. Fix valid findings. For an invalid finding, reply with concrete repository context and request another review. If Greptile still withholds the required 5/5 status, only a member of `@flipbook-labs/flipbook-admins` may bypass it; agents must not bypass merge requirements.


Before you write any code, tests, or PR prose:

1. Install dependencies (this also fetches the skills into the Loom store):

   ```sh
   lute run install
   ```

2. Resolve the concrete skills path (do not guess the version):

   ```sh
   ls -d ~/.loom/store/AgentSkills@*
   ```

   That prints the one installed copy, `~/.loom/store/AgentSkills@v<version>`, where `<version>` is the `rev` pinned for `AgentSkills` in [`loom.config.luau`](loom.config.luau). Use the printed path wherever `<skills>` appears below.

3. Read the routing index at `<skills>/AGENTS.md` in full. Its **Project Skills** section lists every skill with a trigger-rich one-liner, so you know what exists before you start.

Deep reads of individual `<skills>/src/<scope>/<name>/SKILL.md` files stay on demand: when a task matches a trigger from the index, read that skill before doing the work it covers.

Skills are living documents. If your work here contradicts a skill (a renamed symbol, a changed value, a fixed bug it still calls known), fix it in the agent-skills repo and add a `.changes/` entry there in the same PR. The fix reaches this repo on its next `rev` bump.
