---
name: flipbook-build-and-toolchain
description: Understanding the Flipbook build system from environment setup through final deployment; source→rbxm pipeline with deep focus on Darklua require transformation, environment globals injection, and dead-code elimination
---

# Flipbook Build and Toolchain

This skill covers environment setup from scratch, the full toolchain responsibility table, the complete source-to-deployment pipeline (with special focus on Darklua's role), build mechanics including caching and incremental builds, and traps that commonly break builds. The audience understands Rojo and Wally already; Lute and Loom are explained as runtime environments (Lute is Luau's equivalent of Node.js for writing Luau in the Lute runtime).

**Do NOT use this skill for:**
- Release workflows or GitHub Actions orchestration — use `flipbook-release-and-operations`
- Story format, controls, or storybook APIs — use `flipbook-domain-reference`
- Debugging runtime errors in stories or plugins — use `flipbook-debugging-playbook`
- Architecture design or load-bearing invariants — use `flipbook-architecture-contract`

---

## Environment Setup from Scratch

### Prerequisites

- macOS, Linux, or Windows (with WSL2 recommended for path-length safety)
- Roblox Studio installed
- Git
- Internet access (for tool downloads)

### Step 1: Install Pinned CLI Tools

Rokit manages all CLI tool versions. Install once, tools stay in sync across the team:

```bash
rokit install
```

This reads `rokit.toml` and installs to `~/.rokit/` (or a custom ROKIT_HOME). Tools include: darklua 0.17.1, luau-lsp 1.60.1, lune 0.9.4, **lute 1.0.0**, roblox-packages 0.5.0, rocale 0.1.3, rojo 7.6.1, selene 0.30.1, stylua 2.3.1, wally 0.3.2, wally-package-types 1.5.1.

**Why version-pinning matters:** Lute version bumps break APIs (see archaeology: the "upgrade-loom-dependencies" branch stalled after "nightmare" fixes). If a build fails after someone upgrades rokit.toml, revert the change and wait for a proper tested PR.

### Step 2: Install Luau Packages (Loom) and Roblox Packages (Wally)

```bash
lute run install
```

This does the following (from `.lute/install.luau`):

1. **Installs Loom dependencies** (via `lute pkg install`). These are Luau packages for the Lute runtime itself (flipbook-batteries v0.9.0, lute v1.0.0, lute-dotenv v0.1.0). They go to `Packages/`.
2. **Moves Loom packages out of the way.** Since both Wally and Loom write to `Packages/`, the script renames `Packages/` → `LuauPackages/` to avoid collision. Now Wally can populate `Packages/` without seeing Loom's build scripts.
3. **Patches select Wally packages** (luaulog, charm, react-charm) with Darklua to convert their string requires to Roblox requires (they weren't originally written for Flipbook's mixed require style).
4. **Installs Roblox packages** via Wally (Charm 0.11.0-rc.4, React/ReactRoblox 17.0.2 jsdotlua, Storyteller 1.12.0, ModuleLoader 0.11.0, ReactCharm, ReactSpring, Sift, t, Highlighter, Log, sha256, plus dev-only Fusion 0.2.0, Jest 3.10.0, Roact 1.4.4 from `wally.toml`). These land in `Packages/`.

After install, you have:
- `LuauPackages/` — tooling scripts (flipbook-batteries, lute, dotenv)
- `Packages/` — Roblox runtime dependencies (Wally)
- `RobloxPackages/` — roblox-packages CLI installs (Foundation, Promise, Dash)

### Step 3: Copy Environment Template and Set Variables

```bash
cp .env.template .env
```

Edit `.env` and set at least these:
- `BASE_URL=https://apis.flipbooklabs.com` (or local backend URL)
- `LOG_LEVEL=info` (or `debug`, `warn`, `error`)
- `ENABLE_OUTPUT_LOGGING=false` (if `true`, also route Flipbook logs to Studio Output window)
- `ROBLOX_API_KEY=<your-open-cloud-key>` (required only to run tests)

**CI-like contexts** (GitHub Actions, CI runners): CI also copies `.env.template` → `.env` before builds. If `.env` is missing and you try to build, you'll get: "One or more critical environment variables are not set. Please make sure to copy `.env.template` to `.env`."

**Non-obvious variable:** JEST_TEST_PATH_PATTERN is injected by Darklua at build time (when running tests with `--filter`). Don't set it manually — `lute run test --filter "foo"` handles it. ENABLE_OUTPUT_LOGGING is injected by Darklua (per `.darklua.json`); the logger reads `_G.ENABLE_OUTPUT_LOGGING` at runtime.

### Troubleshooting Setup

**Lute or Rokit not found:** rokit installs to `~/.rokit/bin/`. Ensure `~/.rokit/bin/` is in your PATH. On macOS, add to `~/.zshrc` (or `~/.bash_profile`): `export PATH="$HOME/.rokit/bin:$PATH"`.

**Wally/Loom install fails:** Ensure internet is up and GitHub is reachable. If a Wally package is corrupted, delete `Packages/` and `LuauPackages/` and re-run `lute run install`.

**Darklua patching errors:** If `lute run install` fails during patching, check that selected packages (luaulog, charm, react-charm) are present in `Packages/_Index/`. If they're missing, Wally didn't install correctly.

For full setup help including VSCode extensions, see `.agents/skills/setup-flipbook-dev-env` (cross-reference to avoid duplication; focus there is initial onboarding).

---

## Toolchain Responsibility Table

Each tool has a specific, narrow job. Understand which tool does what to debug build failures efficiently.

| Tool | Input | Output | Why We Use It | Failure Mode |
|------|-------|--------|---------------|--------------|
| **Rokit** | `rokit.toml` | CLI tools in `~/.rokit/bin/` | Single source of truth for tool versions; ensures team consistency | Version mismatch on new laptop; old version cached locally |
| **Loom** | `loom.config.luau` | Luau packages in `LuauPackages/` | Fetch runtime libraries (flipbook-batteries, lute, dotenv) for the Lute runtime | Stale package cache; version break (Lute 1.0.0 API changed in minor bump) |
| **Wally** | `wally.toml` | Roblox packages in `Packages/` | Fetch Roblox runtime dependencies (Storyteller, ModuleLoader, React, Charm) | Network timeout; corrupted package index; conflicting semver constraints |
| **Rojo** | `.project.json` tree + source files | `.rbxm` file or sourcemap JSON | Syncs Luau → Roblox Instance hierarchy; generates sourcemaps for Darklua | Project tree misconfigured; invalid $path; circular dependencies in module tree |
| **Darklua** | Luau source with string requires + `.darklua.json` rules | Luau source with Roblox requires | Transforms `require("@pkg/Foo")` → `require(script.Parent.Packages.Foo)` using sourcemap; injects `_G` globals; dead-code stripping | Sourcemap drift (Rojo ran but config changed); stale cache; env vars undefined |
| **Lute** | `.lute/<script>.luau` + args | Task output (built files, published artifacts) | Task runner for all Flipbook scripts (build, test, lint, analyze, etc.) | Malformed Lune Luau; missing dependency; process spawn hanging |

**The crucial boundary:** Wally and Loom both write to `Packages/`. The install script moves Loom → `LuauPackages/` so they don't collide. Never manually move or delete these directories during a build.

---

## Lute and Loom Explained

### Lute

Lute is the **Luau runtime for writing and running Luau scripts outside Roblox** — conceptually equivalent to Node.js for JavaScript. You use it to run build scripts, test infrastructure, and CI automation. Flipbook uses Lute 1.0.0 (pinned in `rokit.toml`).

Key facts:
- Scripts are `.luau` files in `.lute/` that `require` from `LuauPackages/`, `Packages/`, and standard library (`@std/*`)
- Batteries API (from flipbook-batteries@v0.9.0) provides cross-platform file/process/text utilities
- Processes are spawned with `process.run()` or `process.system()` — both differ in stdio and return shape
- Environment variables come from `.env` (loaded by dotenv@0.1.0 in build.luau)
- Errors bubble as assertions; use `assert(result.ok, result.stderr)` to catch failures

Lute version bumps are **painful** (see archaeology: "upgrade-loom-dependencies" branch). APIs change; watch rokit.toml like a hawk.

### Loom

Loom is the **package manager for Luau** — specifically, for packages you use in the Lute runtime or Luau scripts. It fetches GitHub repos and pins them to a `loom.config.luau` manifest. Flipbook's Loom manifest specifies:
- flipbook-batteries v0.9.0 (batteries of utilities: copy, run, find, findAndReplace)
- lute v1.0.0 (runtime typedefs and batteries plugin)
- lute-dotenv v0.1.0 (.env file loader)

These land in `LuauPackages/`, separate from Wally packages. The `.luaurc` alias `"luaupkg": "./LuauPackages"` lets scripts `require("@luaupkg/flipbook-batteries@v0.9.0")`.

---

## The Full Build Pipeline: Source → Deployment

Here is a step-by-step trace of one file's journey from source to the installed plugin.

### Example: `workspace/flipbook-core/src/FlipbookApp.luau`

```
┌─────────────────────────────────────────────────────────────────────┐
│ SOURCE (Luau, string requires)                                      │
│                                                                     │
│  workspace/flipbook-core/src/FlipbookApp.luau:                     │
│    local React = require("@pkg/React")                             │
│    local Charm = require("@pkg/Charm")                             │
│    local FlipbookCore = require("@workspace/flipbook-core/src")    │
└─────────────────────────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────┐
       │ STEP 1: Rojo Sourcemap Generation                │
       │ Command: rojo sourcemap sourcemap.project.json   │
       │          -o sourcemap-darklua.json               │
       │                                                   │
       │ Output: sourcemap-darklua.json (JSON map of      │
       │ Luau paths → Roblox require() paths)             │
       │ Example entry:                                    │
       │   "src/FlipbookApp.luau" → "script.Parent.src... │
       └───────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────────┐
       │ STEP 2: Darklua Convert Requires (Major Transform)   │
       │ Command: darklua process src build/dev/roblox       │
       │ Config (.darklua.json):                             │
       │   - Rule: convert_require (Luau → Roblox using      │
       │     sourcemap-darklua.json + indexing_style:        │
       │     property)                                        │
       │   - Aliases: @pkg → script.Parent.Packages, etc.    │
       │ Output: Luau with Roblox property-access requires  │
       │                                                      │
       │ After Darklua on FlipbookApp.luau:                  │
       │   local React = require(script.Parent.Packages.React)
       │   local Charm = require(script.Parent.Packages.Charm)
       │   local FlipbookCore = require(script.Parent...     │
       │     workspace.["flipbook-core"].src)               │
       └───────────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────────┐
       │ STEP 3: Inject Global Values (Env Vars)             │
       │ Darklua continues with inject_global_value rules.   │
       │ All 8 globals from .darklua.json (env injections):  │
       │   - BUILD_VERSION (from wally.toml: 2.5.0)          │
       │   - BUILD_CHANNEL ("production", "beta", or dev)    │
       │   - BUILD_HASH (git rev-parse --short HEAD)         │
       │   - BUILD_TARGET ("roblox" or "rotriever")          │
       │   - BASE_URL (from .env)                            │
       │   - LOG_LEVEL (from .env)                           │
       │   - ENABLE_OUTPUT_LOGGING (from .env)               │
       │   - JEST_TEST_PATH_PATTERN (for test filtering)    │
       │ Result: _G vars available at module init time       │
       └───────────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────────┐
       │ STEP 4: Dead-Code Elimination (Channel Gating)      │
       │ Darklua rules: compute_expression, remove_unused_if │
       │ _branch, remove_unused_while, filter_after_early... │
       │ Effect: if BUILD_CHANNEL == "development" then      │
       │         code inside if-block is PHYSICALLY DELETED  │
       │         at compile time (prod build omits tests)    │
       │ Prod build erases: code-samples/, example/,         │
       │ template/, test-runner/ directories + *.spec.luau*  │
       │ *.story.luau*, *.storybook.luau* files              │
       └───────────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────────┐
       │ STEP 5: Copy Dependencies                            │
       │ runBuildGroupAsync step (incremental):              │
       │   - Hash each of Packages/ and RobloxPackages/       │
       │   - If changed or --clean: copyInto() to build dest  │
       │ Result: build/dev/roblox/ now contains:             │
       │   - src/ (Darklua-transformed)                       │
       │   - Packages/ (Wally installs)                       │
       │   - RobloxPackages/ (roblox-packages installs)      │
       │   - workspace/ (all members)                         │
       └───────────────────────────────────────────────────────┘
                               ↓
       ┌───────────────────────────────────────────────────────┐
       │ STEP 6: Rojo Build to .rbxm                          │
       │ Command: rojo build temp-12345.project.json          │
       │          --output Flipbook.rbxm                      │
       │ Input: build/dev/roblox/ (Luau tree)                │
       │ Output: Flipbook.rbxm (binary Instance tree)         │
       │ The .project.json is ephemeral (deleted after use)   │
       └───────────────────────────────────────────────────────┘
                               ↓
   ┌─────────────────────────────────────────────────────────────┐
   │ RESULT: Flipbook.rbxm                                       │
   │ Installed to Studio plugins dir by hot-reload:             │
   │   macOS: ~/Library/Application Support/Roblox/             │
   │           Versions/{version}/ClientSettings/plugins/        │
   │   Windows: %APPDATA%\Roblox\Versions\...                   │
   │   Linux: ~/.local/share/Roblox/...                         │
   │ Studio automatically reloads on next focus unless           │
   │ --skip-reload is set.                                       │
   └─────────────────────────────────────────────────────────────┘
```

### Key Insight: Why Darklua Gets Deep Treatment

**The problem:** Roblox requires property-access syntax (`require(script.Parent.Foo)`), but Luau scripts ergonomically use string requires (`require("@pkg/Foo")`). They can't coexist natively.

**Darklua's solution:** Static code transformation at compile time. Because Rojo generates a sourcemap that maps every source file to its target location in the Roblox tree, Darklua can rewrite every string require to its property-access equivalent. This happens **once per build**, not at runtime, so there's no performance cost.

**The `.darklua.json` config** specifies 8 transformation rules in sequence:
1. `convert_require` — main transformation (uses sourcemap + `indexing_style: property`)
2. Eight `inject_global_value` rules — one per `_G` variable (BUILD_VERSION, BUILD_CHANNEL, BUILD_HASH, BUILD_TARGET, BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING, JEST_TEST_PATH_PATTERN)
3. Dead-code-elimination rules (compute_expression, remove_unused_if_branch, remove_unused_while, filter_after_early_return, remove_nil_declaration, remove_empty_do) — these allow `if BUILD_CHANNEL == "development" then ... end` to vanish in prod builds

**Why sourcemap matters:** If Rojo's sourcemap (from `sourcemap.project.json`) doesn't match the actual Luau tree structure, Darklua can't find files and will error. If `.luaurc` aliases are stale or `.darklua.json` references a missing file, the build halts. This is "sourcemap drift" — a known trap.

---

## Build Subcommands, Channels, and Targets

All builds go through `.lute/build.luau` (CLI parser + logic) and `.lute/lib/build-system/` (compileAsync, runBuildGroupAsync, caching).

### Subcommands

- **`plugin`** (default) — Build the main Flipbook plugin (.rbxm). Output: `build/dev|prod|beta/roblox/Flipbook.rbxm`.
- **`workspace`** — Build all workspace members. Used by CI to verify the workspace compiles. Output: `build/dev|prod|beta/roblox/workspace/`.
- **`storybook`** — Build a test storybook place (for deploy-storybook). Output: `build/flipbook-storybook.rbxl`.

### Channels

Channels control which code is included in the build:

- **`dev`** (default in most workflows) — Keeps all code: tests (`*.spec.luau`), stories (`*.story.luau`), storybooks (`*.storybook.luau`). Useful for developing Flipbook itself. `BUILD_CHANNEL` → `"development"`.
- **`beta`** — Intermediate; prod pruning but with different asset mappings. `BUILD_CHANNEL` → `"beta"`. Used for nightly releases.
- **`prod`** — Strips all test and story code. Directories pruned: code-samples/, example/, template/, test-runner/. Files pruned: `*.spec.luau*`, `*.story.luau*`, `*.storybook.luau*`, `jest.config.luau*`. `BUILD_CHANNEL` → `"production"`.

Pruning happens at **compile time** via Darklua's dead-code elimination. The directories and files are physically deleted from `build/` before Rojo packs the .rbxm.

### Targets

- **`roblox`** (default) — Build plugin for Roblox Studio. Output: standard plugin .rbxm.
- **`rotriever`** — Build FlipbookCore as a Rotriever package (for internal Roblox Studio use). Special handling in compileAsync.luau:
  - Strips out plugin entry points (PluginStarterScript, EmbeddedClientStarterScript, EmbeddedServerStarterScript)
  - Bundles `Packages/` and `RobloxPackages/` directories into `.rbxms` to mitigate Windows path-length limits (Windows MAX_PATH = 260 chars; deeply nested packages exceeded this when consumed by internal tools)
  - Renames all `.luau` files to `.lua` (Rotriever doesn't support `.luau` extension)
  - Outputs to `build/flipbook-core-rotriever/`

### Example Build Commands

```bash
# Dev build (keep tests/stories) to Studio plugins dir, watch for changes
lute run build plugin --channel dev --watch

# Prod build (strip tests/stories) as standalone file
lute run build plugin --channel prod --output ~/Desktop/Flipbook.rbxm

# Clean rebuild (delete cached build, full recompile)
lute run build plugin --channel dev --clean

# Rotriever bundle (internal use)
lute run build --target rotriever --channel prod

# Skip Studio reload (useful if Studio is frozen)
lute run build plugin --channel dev --skip-reload
```

---

## Build Cache and Incremental Builds

Flipbook uses an incremental build system to speed up dev iteration. The cache is stored in `build/build-cache.json`.

### How It Works

**`runBuildGroupAsync`** in `.lute/lib/build-system/runBuildGroupAsync.luau` hashes each input path (Packages/, workspace members, etc.) and compares it to the cached hash. If hashes match and `--clean` is not set, the build step is **skipped** — the files are already built. If hashes don't match or `--clean` is set, the step runs and the cache is updated.

**Cache key:** `"{channel}-{target}-{path}"` — the same files are cached separately for each channel/target combo.

**Gotchas:**

- **Stale cache:** If you edit `Packages/` by hand (bad idea, but happens), the hash might not change (shallow hashing). Use `--clean` to force a full rebuild.
- **Cross-channel contamination:** If you build dev, then build prod, each uses its own cache entry. Cache is isolated correctly.
- **Cache deletion:** To nuke the cache and start fresh: `rm build/build-cache.json` (or use `--clean` every time, but it's slower).

---

## Environment Globals (The 8 Injected `_G` Variables)

Darklua injects these globals at compile time. They are available in any module without explicit passing:

| Global | Source | Typical Value | Usage |
|--------|--------|----------------|-------|
| **BUILD_VERSION** | wally.toml version | "2.5.0" | Plugin display version, telemetry, feature flags |
| **BUILD_CHANNEL** | Channel arg | "development", "beta", "production" | `if BUILD_CHANNEL == "development" then ... end` for dev-only code |
| **BUILD_HASH** | `git rev-parse --short HEAD` | "a1b2c3d" | Telemetry, debug logs, artifact traceability |
| **BUILD_TARGET** | Target arg | "roblox" or "rotriever" | Conditional code for different deployment targets |
| **BASE_URL** | .env variable | "https://apis.flipbooklabs.com" | HTTP requests to telemetry backend |
| **LOG_LEVEL** | .env variable | "info", "debug", "warn", "error" | Controls logger verbosity |
| **ENABLE_OUTPUT_LOGGING** | .env variable | "false" or "true" | Toggle Flipbook logs in Studio Output window (noisy) |
| **JEST_TEST_PATH_PATTERN** | Darklua global, `--filter` arg | e.g., "controls" | Test filtering; injected only when running `lute run test --filter` |

**Accessing them:** Use directly: `print(BUILD_VERSION)`. The variables are lexically scoped at module init (not available in functions defined at top-level, only if used immediately). If you need a global inside a function, assign to a local at module top: `local version = BUILD_VERSION`.

**If not set:** Darklua replaces undefined injections with `nil`. If you try to build without `.env`, BUILD_URL becomes nil, and http requests fail with "URL must be http". CI catches this with an assertion in `.lute/build.luau` line 100–105.

---

## Known Traps and Mitigations

### 1. Sourcemap Drift

**Trap:** Rojo sourcemap is stale, Darklua can't resolve requires.

**Symptom:** `darklua process` fails: "can't find module at path X".

**Cause:** `.luaurc` aliases changed, source tree was moved, or `sourcemap.project.json` wasn't updated.

**Fix:** Regenerate the sourcemap with `rojo sourcemap sourcemap.project.json -o sourcemap-darklua.json` (this is done automatically in compileAsync, but if you're debugging, run it manually).

### 2. Stale Cache

**Trap:** Build uses old binary from cache after you edit Packages/ manually.

**Symptom:** Build succeeds but changes to dependencies don't appear in plugin.

**Fix:** `lute run build plugin --channel dev --clean` (forces full rebuild).

### 3. Missing `.env`

**Trap:** CI or local build missing `.env` file.

**Symptom:** "One or more critical environment variables are not set."

**Fix:** `cp .env.template .env` and populate. In CI, workflows copy the template before building (see ci.yml).

### 4. Windows Path Length (Mostly Fixed)

**Trap:** On Windows, deeply nested Wally packages exceed MAX_PATH (260 chars).

**Mitigation:** Rotriever builds (target=rotriever, step 5 in pipeline diagram) bundle packages into .rbxms before consumption (compileAsync.luau lines 99–110). Reduces nesting depth. This is permanent, not a workaround.

**If you hit this:** Switch to Linux or WSL2 for development. Report to maintainer if building on Windows with --target=roblox fails.

### 5. Lute Version Bump Pain

**Trap:** Upgrading lute in rokit.toml breaks build scripts because APIs changed.

**Symptom:** `process.run()` returns different shape, batteries functions moved, typedefs don't exist.

**Example:** Branch `upgrade-loom-dependencies` attempted Lute bump; needed ~6 fixes, then stalled.

**Mitigation:** Before bumping Lute, read the changelog. When you do bump, test exhaustively (run all build subcommands, watch mode, rotriever target, CI matrix). Expect to fix `.lute/build.luau`, `.lute/install.luau`, and battery wrapper calls.

### 6. .darklua.json Config Typo

**Trap:** Misspelled env var name or missing rule in .darklua.json.

**Symptom:** Build succeeds but global is nil at runtime.

**Fix:** Cross-check env variable names against the config. All 8 rules must be present (lines 14–53 in repo `.darklua.json`). Common typo: `BUILD_CHANNEL` vs `BUILD_CHANEL`.

### 7. Rotriever Path-Length Mitigation Regression

**Trap:** If you remove or disable the `packToRbxm()` call in compileAsync.luau (lines 99–110), Windows path-length errors resurface when consuming via Rotriever.

**Mitigation:** Never remove the rbxm bundling without understanding the full fallout. This was the permanent fix to PR #523's saga. Comment at line 99 is the rationale.

### 8. Charm.flags.frozen Workaround Required

**Trap:** (Not directly a build trap, but related to state bugs.) Storyteller has an unresolved mutation bug (storyteller/issues/100) that causes "Attempt to modify a readonly table" when Charm.flags.frozen=true.

**Mitigation:** `src/PluginStarterScript.plugin.luau` sets `Charm.flags.frozen = false` at startup. This is a known trade-off. **Do not remove this line** — tests pass, but stories will crash at runtime.

---

## Build Cache Internals: Hash, Incremental, Watch

The cache file (`build/build-cache.json`) is a JSON object mapping `{channel}-{target}-{path}` to a content hash. Example:

```json
{
  "dev-roblox-/path/to/Packages": "sha256:abc123...",
  "dev-roblox-/path/to/workspace/flipbook-core": "sha256:def456..."
}
```

**Hash computation:** `hashPath()` in `.lute/lib/build-system/hashPath.luau` walks a directory tree and hashes file contents (recursive, deterministic).

**Incremental rebuild:** When you run `lute run build plugin --channel dev --watch`:
1. Initial build: all paths hashed, cache populated, binaries emitted.
2. Edit a story file in workspace/flipbook-core/src/.
3. Watcher detects change.
4. Rebuild: `runBuildGroupAsync` re-hashes workspace/flipbook-core (hash differs).
5. Only the flipbook-core compile step runs; Packages/ step is skipped.
6. New .rbxm is built, Studio reloads.

**Watch mode:** Uses Lute's `watch()` from flipbook-batteries. Watches source files and re-invokes build script on change. Saves ~5-10 seconds per iteration vs. `--clean` rebuilds.

---

## ASCII Pipeline Diagram

```
                         ┌──────────────────┐
                         │   SOURCE FILES   │
                         │   (Luau code)    │
                         │  string requires │
                         └────────┬─────────┘
                                  │
                    ┌─────────────┴──────────────┐
                    │                            │
          ┌─────────▼──────────┐      ┌─────────▼──────────┐
          │  Rojo Sourcemap    │      │   Darklua Config   │
          │ (map paths)        │      │  (.darklua.json)   │
          └─────────┬──────────┘      └─────────┬──────────┘
                    │                            │
                    └─────────────┬──────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │   Darklua Transform       │
                    │ (string requires → Roblox,│
                    │  inject _G globals,       │
                    │  dead-code strip)         │
                    └─────────────┬──────────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │  Transformed Luau Code    │
                    │  (Roblox requires,        │
                    │   no dev code in prod)    │
                    └─────────────┬──────────────┘
                                  │
          ┌─────────┬─────────────▼─────────────┬─────────┐
          │         │                           │         │
    ┌─────▼──┐ ┌────▼─────┐ ┌────────────┐ ┌───▼────┐ ┌──▼────┐
    │  Copy  │ │  Wally   │ │  RobloxPkg │ │ Copy   │ │Prune  │
    │  Files │ │ Packages │ │ Packages   │ │Workspace │Folders │
    └─────┬──┘ └────┬─────┘ └────────────┘ └───┬────┘ └──┬────┘
          │         │            │              │       │
          └────────────────────────┬──────────────┬──────┘
                                   │
                    ┌──────────────▼────────────┐
                    │  Complete Build Tree      │
                    │  build/dev|prod|beta/     │
                    │  roblox/                  │
                    └──────────────┬────────────┘
                                   │
                    ┌──────────────▼────────────┐
                    │   Rojo Build              │
                    │  (Luau → Roblox Instance)│
                    └──────────────┬────────────┘
                                   │
                    ┌──────────────▼────────────┐
                    │   Flipbook.rbxm           │
                    │  (Binary plugin)          │
                    └──────────────┬────────────┘
                                   │
                    ┌──────────────▼────────────┐
                    │  Install to Studio Plugins│
                    │  (hot-reload if Studio up)│
                    └──────────────────────────┘
```

---

## Verification Commands

To verify the build system is working:

```bash
# Test basic build (dev channel, plugin subcommand)
lute run build plugin --channel dev --clean

# Test prod build and verify files were pruned
lute run build plugin --channel prod --clean
ls build/prod/roblox/workspace/code-samples
# Should be empty (directory pruned) or not exist

# Test watch mode (Ctrl+C to stop)
lute run build plugin --channel dev --watch

# Verify sourcemap generation
rojo sourcemap sourcemap.project.json -o sourcemap-darklua.json
head sourcemap-darklua.json

# Verify Darklua transformation (manual, for debugging)
darklua process src /tmp/darklua-out --config .darklua.json
grep "require(script" /tmp/darklua-out/PluginStarterScript.plugin.luau | head -5

# Verify .env is loaded
lute run build plugin --channel dev 2>&1 | grep -i "BUILD_VERSION"
# Should print injected globals
```

---

## Provenance and Maintenance

Re-verify these facts against the repo before relying on them for a high-stakes decision:

- **Darklua version and features:** Check `rokit.toml` line 7 (currently 0.17.1). Run `darklua --help` to see available rules.
- **Lute version and API:** Check `rokit.toml` line 10 (currently 1.0.0). If bumped, re-test all build subcommands.
- **Environment variable injection:** Verify `.darklua.json` lines 14–53 match the 8 globals documented above. Count them to ensure all 8 are present.
- **Studio plugins path:** `getStudioPluginsPath.luau` resolves OS-specific paths. Run `lute run build --help` to see default output path.
- **Path-length mitigation:** Verify `compileAsync.luau` lines 99–110 still call `packToRbxm()` for Rotriever target. If missing, Windows consumers will hit MAX_PATH errors.
- **Channels and targets:** Check `.lute/build.luau` lines 70–79 (channel parser) and 76–79 (target parser). Currently support dev/beta/prod and roblox/rotriever.
- **Prod pruning rules:** Verify `project.luau` lines 28–41 (PROD_CONFIG.prunedDirs and prunedFiles) match the actual directories/patterns you want stripped.

---

## Related Documentation

- **Setup onboarding (no duplication):** `.agents/skills/setup-flipbook-dev-env` — walks through rokit, lute, .env, and VSCode config.
- **Test running:** `flipbook-validation-and-qa` skill — covers `lute run test`, Jest filtering, CI test matrix.
- **Architecture:** `flipbook-architecture-contract` skill — load-bearing design decisions (Darklua choice, why string requires matter, Storyteller contracts).
- **Debugging:** `flipbook-debugging-playbook` skill — when builds fail, traps with stories, discriminating experiments.
- **Release pipeline:** `flipbook-release-and-operations` skill — nightly/smoketest/Creator Store publish, artifact naming.
