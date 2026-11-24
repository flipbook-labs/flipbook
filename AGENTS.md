# Flipbook - Agent Instructions

## Repo Overview

Flipbook is a Roblox Studio plugin for browsing and testing UI stories. The dependency chain is:

```
Flipbook  ←  Storyteller  ←  ModuleLoader
```

All three repos (`flipbook`, `storyteller`, `module-loader`) use the same toolchain and conventions, and are expected to be checked out as siblings on disk (e.g. `~/git/flipbook`, `~/git/storyteller`, `~/git/module-loader`).

---

## Tech Stack

| Tool                     | Role                                                                               |
| ------------------------ | ---------------------------------------------------------------------------------- |
| **Lute**                 | Task runner for all scripts (`lute run <script>`)                                  |
| **Rokit**                | Toolchain version manager (`rokit install` pins tools from `rokit.toml`)           |
| **Wally**                | Roblox package manager (Roblox runtime deps)                                       |
| **Lute packages**        | Tooling dependencies for scripts, declared in `pkg.luau` and vendored into `.lpm/` |
| **Rojo**                 | Syncs Luau source trees to Roblox place format; used for sourcemaps and builds     |
| **CodeQuality**          | Shared lint rules, and the code mods that turn string requires into Roblox ones    |
| **Rocale**               | Roblox Open Cloud CLI; uploads and runs test places in the cloud                   |
| **Jest** (jsdotlua)      | Unit test framework; tests run inside a Roblox place via Rocale                    |
| **StyLua**               | Luau formatter                                                                     |
| **CodeQuality**          | Shared Luau lint rules; `lute run lint` runs them with `lute lint`                 |
| **React** (17, jsdotlua) | UI framework used throughout Flipbook and Storyteller                              |
| **Charm**                | Reactive signals library; used for stores in both Flipbook and Storyteller         |
| **ModuleLoader**         | Bypasses Roblox's require cache; core to how Flipbook reloads stories              |
| **Storyteller**          | Story discovery, loading, and rendering; wraps ModuleLoader                        |

---

## Repository Layout

### Flipbook

```
flipbook/
├── .claude/skills/         # Flipbook agent skills (see Skills below)
├── src/                    # Thin plugin entry point (Studio bootstrap only)
├── workspace/              # Real application code, organized as workspace members:
│   ├── flipbook-core/      # Main library — React app, story browser, telemetry, settings
│   ├── flipbook-agents/    # AgentGateway actions, controller lifecycle, and protocol types
│   ├── flipbook-next/      # Experimental next-gen package
│   ├── test-runner/        # Runs Jest.runCLI against flipbook-core tests
│   ├── example/            # Dogfood stories/components
│   ├── code-samples/       # Sample stories for Roact, Fusion, React+Storyteller
│   ├── template/           # Scaffold for new workspace members
│   └── shared.luau         # Version and package files every member's pkg.luau reads
├── build/                  # Build output (gitignored):
│   ├── dev/roblox/         # Dev plugin build
│   ├── prod/roblox/        # Production build
│   └── flipbook-core-rotriever/  # Rotriever bundle for Studio-internal Flipbook
├── .lute/                  # Lute task scripts
├── Packages/               # Wally installs (gitignored)
├── .lpm/                   # Lute packages vendored by `lute run install` (gitignored)
├── LuauPackages/           # rbxasset only
├── RobloxPackages/         # roblox-packages CLI installs (Foundation, Promise, Dash, etc.)
├── project.luau            # Shared path constants used by all Lute scripts
├── wally.toml              # Roblox runtime dependencies
├── pkg.luau                # Virtual root manifest: workspace members plus Lute tooling (batteries, flipbook-batteries; agent-skills and code-quality dev deps)
├── pkg.lock.luau           # Lute package lockfile
├── .config.luau            # Luau aliases, including `@lpm` for the vendored Lute packages
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
├── .lpm/                   # Lute packages vendored by `lute run install`
├── project.luau            # Shared path constants
├── wally.toml              # Package metadata + dependencies
└── pkg.luau                # Lute package manifest
```

Build output (`dist/`) mirrors `src/` with Luau-style requires converted to Roblox `require()` calls. **Wally publishes from `dist/`**, not `src/`.

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
- **Luau linter:** `lute lint` with the CodeQuality rules, run by `lute run lint`. `global_usage` is off in `.config.luau`.
- **Markdown, YAML, JSON, and docs-site formatter:** Prettier, with one config at the repo root (`.prettierrc.json`, `.prettierignore`). Run `lute run check-docs` to check every file; run `npm --prefix docs/site run format` to auto-fix.
- **Test files:** `*.spec.luau` colocated with source files. Jest config uses `testMatch = { "**/*.spec" }`.
- **Imports:** In source, use Luau-style path aliases (`@pkg/Charm`, `@workspace/flipbook-core/src`, etc.); the build converts these to Roblox `require()` calls.

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

`workspace/` is a Lute package workspace. The root `pkg.luau` has no name or version, which makes it a virtual root, and each member is a path dependency in it. Each member has its own `pkg.luau`, `src/`, and sometimes `rotriever.toml`, and reads its version and `files` from `workspace/shared.luau`. Members in the root's `dependencies` ship with the plugin. Members in its `dev_dependencies` are development-only, and production builds prune them. `project.luau` reads both lists from `pkg.luau`, so registering a member there is what makes the build compile it. Members' Roblox dependencies still come from Wally and `roblox-packages`, not `pkg.luau`.

### Wally vs Lute packages

- **Wally** (`Packages/`) installs Roblox runtime deps (React, Charm, Storyteller, ModuleLoader, etc.)
- **Lute packages** are the tooling that `.lute/` scripts use, declared in `pkg.luau` with lowercase kebab-case keys. `lute run install` runs `lute pkg install --vendor`, which copies each one into a gitignored `.lpm/<key>@<rev>` folder. `.config.luau` has one alias for all of them, `lpm = "./.lpm"`, so scripts require a dependency through its folder, as in `require("@lpm/batteries@v1.0.1-nightly.20261115/cli")`. A vendored package's own `@lpm` requires resolve through this repo's alias, so the alias has to stay; [#694](https://github.com/flipbook-labs/flipbook/issues/694) tracks removing that requirement. Scripts load `.env` with flipbook-batteries' `dotenv`. The shared skill library is the `agent-skills` dev dependency, vendored into `.lpm/agent-skills@<rev>` for agents to read (not required at runtime). The `code-quality` dev dependency holds the CodeQuality lint rules, which `.lute/lint.luau` points `lute lint` at
- `LuauPackages/` holds only rbxasset, which `.lune/publish-plugin.luau` requires as `@lunepkg`. Lune reads aliases only from `.luaurc`, so `.lune/.luaurc` declares the Lune aliases

### The build and require paths

Source files use Luau-style aliases (`@pkg/`, `@workspace/`, `@repo/`, etc.). The build copies `src/` into `build/<channel>/<target>/`, and each workspace member's `src/` into its own `build/` folder, then runs [CodeQuality](https://github.com/flipbook-labs/code-quality)'s code mods over the copies (`.lute/lib/build-system/runCodeModsAsync.luau`). `convertRequire` resolves each require through the nearest `.config.luau` or `.luaurc` (the root `src/` uses the root `.config.luau`, and each workspace member has its own `.luaurc`), then writes the Roblox `require(script.X)` path from a Rojo sourcemap. A require it can't resolve fails the build. `injectGlobalValue` fills in the build globals listed in `project.luau`'s `BUILD_GLOBALS`, and the cleanup mods remove the branches those values make unreachable. **Never edit files in `build/` or `dist/` directly.**

---

## Skills

Flipbook's own design contracts and runbooks live in [`.claude/skills/`](.claude/skills/), next to the code they describe. Cross-cutting doctrine that applies to every flipbook-labs repo, such as writing style, Luau style, tests, and changelog entries, lives in the org's shared [AgentSkills](https://github.com/flipbook-labs/agent-skills) library. Routing is manual and on demand: read both indexes up front, then read a skill before doing the work it covers.

Before preparing, reviewing, or merging a pull request, read [.github/MERGE_POLICY.md](.github/MERGE_POLICY.md). When the change touches releases, workflows, telemetry, or dependencies, also read the [`release`](.claude/skills/release/SKILL.md) skill. Ownership is inferred from changed files. Mixed application and engine changes require application review. Workspace release manifests are an explicit engine-owned exception; every other path outside the application domain, including repository-stewardship files, also belongs to `@flipbook-labs/flipbook-engine`.

Preserve `.github/pull_request_template.md` instead of replacing it with an agent-authored structure. For user-visible changes, include visual evidence that lets the application reviewer evaluate the result.

Greptile must treat this file, `.github/MERGE_POLICY.md`, and the relevant skills as authoritative repository guidance. The repositories listed in `.greptile/config.json` provide shared conventions and cross-repository implementation context. Keep `.greptile/files.json` limited to stable initial context, then follow this index and the changed code into specialized skills. When sources conflict, prefer this repository and then the shared skills. Assess implementation safety independently from merge authorization: a change requiring human application approval is not inherently lower quality.

Greptile findings must be evaluated rather than accepted mechanically. Fix valid findings. For an invalid finding, reply with concrete repository context and request another review. If Greptile still withholds the required 5/5 status, only a member of `@flipbook-labs/flipbook-admins` may bypass it; agents must not bypass merge requirements.

### Flipbook skills

- [`architecture`](.claude/skills/architecture/SKILL.md): the contracts the code does not make obvious. Pluginlike and embedding, the Flipbook to Storyteller to ModuleLoader layering, why state lives in Charm, reload behavior, plugin versus embedded limits, and the community-first policy for the internal build, telemetry, and claims about other tools. Use when changing embedding or bootstrap code, story loading, stores, telemetry, or the internal build.
- [`dev-env`](.claude/skills/dev-env/SKILL.md): set up, repair, and validate the environment. Installs, `.env`, lint, analyze, cloud tests and their Open Cloud key, testing local Storyteller or ModuleLoader changes in Flipbook, StudioPlugins, and what counts as evidence for a fix. Use when setting up, running checks, when tests cannot run, or when testing a dependency change in Flipbook.
- [`release`](.claude/skills/release/SKILL.md): how releases happen and what an agent must not do in them. Channels and assets, CI environments and secrets, storybook previews, PostHog release reporting, and the rules for telemetry, community parity, and dependency bumps. Use when a change touches releases, publishing, workflows, telemetry, or dependencies.
- [`troubleshooting`](.claude/skills/troubleshooting/SKILL.md): non-obvious runtime and build failures, past incidents not to repeat, and measurement techniques. Use when the plugin is stale, an injected global is wrong, tests wait on a fork PR, a Windows or Rotriever build breaks, or you need evidence for a build or re-render fix.
- [`use-studio-mcp`](.claude/skills/use-studio-mcp/SKILL.md): build and validate Flipbook through Studio MCP and FlipbookAgentGateway. Use when driving a local build, changing gateway actions, or verifying Stories through semantic actions, embedded Play-mode input, and screenshots.
- [`write-docs`](.claude/skills/write-docs/SKILL.md): authoring the docs site. Where pages live, the sidebar, code samples, and grounding every claim in source. Use when writing or editing anything under `docs/`.

These skills change with the code. When a change renames a symbol, changes a value, or fixes a bug that one of them describes, update the skill in the same pull request. Adding, renaming, or removing a skill means updating this index too.

### Shared skills: flipbook-labs/agent-skills

The shared library is pinned as a dev dependency in [`pkg.luau`](pkg.luau). Before you write any code, tests, or PR prose:

1. Install dependencies (this also vendors the skills into `.lpm/`):

   ```sh
   lute run install
   ```

2. Find the skills folder: it's `.lpm/agent-skills@<rev>`, where `<rev>` is the `agent-skills` rev in [`pkg.luau`](pkg.luau). Use that path wherever `<skills>` appears below.

3. Read the routing index at `<skills>/AGENTS.md` in full. Its **Project Skills** section lists every skill with a trigger-rich one-liner, so you know what exists before you start.

Deep reads of individual `<skills>/src/<scope>/<name>/SKILL.md` files stay on demand: when a task matches a trigger from the index, read that skill before doing the work it covers.

If your work here contradicts a shared skill, fix it in the agent-skills repo and add a `.changes/` entry there in the same PR. The fix reaches this repo on its next `rev` bump.
