---
name: flipbook-config-and-flags
description: Configuration axes (env vars, injected globals, build channels/targets, user settings); adding new config; re-verification commands
---

# Flipbook Configuration & Flags

This skill catalogs every configuration axis in Flipbook: environment variables, build-time injected globals, build channels and targets, user-settable preferences, and structural constants. Use this to understand how the system is configured, extend it with new options, or debug drift.

**When to use:** extending Flipbook's configuration surface; understanding how a setting flows from env → code → runtime behavior; verifying that config options are documented correctly.

**When NOT to use:** for build pipeline mechanics, use `flipbook-build-and-toolchain`; for telemetry strategy specifics, use `flipbook-config-and-flags` (sections 5 and A); for release workflows, use `flipbook-release-and-operations`.

---

## 1. Environment Variables (.env)

All environment variables are read from `.env` (loaded by `lute run build`); `.env.template` is the public contract.

| Name | Purpose | Default | Values | Prod vs Experimental | Where Used |
|------|---------|---------|--------|---------------------|------------|
| `LOG_LEVEL` | Min verbosity for logs sent to Help > Logs | `info` | `trace`, `debug`, `info`, `warn`, `error`, `fatal` | Production | `workspace/flipbook-core/src/logger.luau:35` sets `MinLevelFilter(_G.LOG_LEVEL)` |
| `ENABLE_OUTPUT_LOGGING` | Route logs to Studio Output window (in addition to Logs view) | `false` | `true` or `false` | Production | `workspace/flipbook-core/src/logger.luau:33` checks `_G.ENABLE_OUTPUT_LOGGING == "true"` |
| `BASE_URL` | Telemetry and feedback backend endpoint | `https://apis.flipbooklabs.com` | Valid HTTPS URL | Production | `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:28`, `workspace/flipbook-core/src/Feedback/postFeedbackAsync.luau:6` build both requests to `{_G.BASE_URL}/<endpoint>` |
| `ROBLOX_API_KEY` | Open Cloud API key for cloud Jest test execution | (required, no default) | Valid Open Cloud key | Production | `.lute/build.luau:24` loads via `dotenv.config()`; used by test runner only |
| `ROBLOX_UNIT_TESTING_PLACE_ID` | Test place for cloud Jest execution | `123506190725771` | Roblox place ID | Production | `.env.template:21` and build system |
| `ROBLOX_UNIT_TESTING_UNIVERSE_ID` | Test universe for cloud Jest execution | `6599100156` | Roblox universe ID | Production | `.env.template:22` and build system |

**Verification:** `grep -r "process.env\|dotenv" .lute .env.template`.

---

## 2. Build-Time Injected Globals (_G)

Darklua (`.darklua.json`) injects these 8 globals from environment at build time, followed by dead-code elimination so channel-gated branches are pruned:

| Name | Purpose | Source | Read Locations | Prod vs Experimental |
|------|---------|--------|---|---|
| `BUILD_VERSION` | Package version from `wally.toml` | `wally.toml:package.version` (read by `.lute/build.luau:113`) | `workspace/flipbook-core/src/About/BuildInfo.luau:2`, `workspace/flipbook-core/src/About/AboutView.luau:1`, `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:21` | Production |
| `BUILD_CHANNEL` | Normalized channel name: "production" \| "beta" \| "development" | `.lute/build.luau:114` maps `channel` arg to enum | `workspace/flipbook-core/src/FlipbookApp.luau:99-100` (show badges), `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:22` | Production |
| `BUILD_HASH` | Short commit hash (git rev-parse --short HEAD) | `.lute/build.luau:115` | `workspace/flipbook-core/src/About/BuildInfo.luau:3`, `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:23` | Production |
| `BUILD_TARGET` | Build target: "roblox" \| "rotriever" | `.lute/build.luau:116` | `workspace/flipbook-core/src/FlipbookApp.luau:101` (show internal badge for rotriever) | Production |
| `BASE_URL` | Telemetry backend URL (from .env) | `.lute/build.luau:117` reads `process.env.BASE_URL` | `workspace/flipbook-core/src/Feedback/postFeedbackAsync.luau:6`, `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:28` | Production |
| `LOG_LEVEL` | Min log level (from .env) | `.lute/build.luau:118` reads `process.env.LOG_LEVEL` | `workspace/flipbook-core/src/logger.luau:35` | Production |
| `ENABLE_OUTPUT_LOGGING` | Output logging flag (from .env) | `.lute/build.luau:119` reads `process.env.ENABLE_OUTPUT_LOGGING`; injected by Darklua into `_G.ENABLE_OUTPUT_LOGGING` | `workspace/flipbook-core/src/logger.luau:33` checks `_G.ENABLE_OUTPUT_LOGGING == "true"` | Production |
| `JEST_TEST_PATH_PATTERN` | Test file filter (Jest `testMatch` pattern) | `.lute/build.luau` via `--filter` arg; injected by darklua for test builds only | Inlined in test Jest config (not directly grepped in src/) | Experimental — test builds only |

**Verification:** `grep -r "inject_global_value" .darklua.json` lists the 8 rules.

---

## 3. Build Axes: Channels & Targets

### Channels

Determine which code is included in the binary. Passed via `--channel` flag to `lute run build <subcommand>`.

| Channel | Default? | What It Does | Dead-Code Stripping | Pruned Dirs | Pruned Files | Use Case |
|---------|----------|---|---|---|---|---|
| `dev` | No | Keeps all sources: tests, stories, storybooks, code samples | No pruning | None | None | Local development; working on Flipbook itself |
| `beta` | No | Full code (like `dev`) | No pruning | None | None | Beta releases (planned; not currently shipped) |
| `prod` | **Yes** — default in `.lute/build.luau:39` | Strips test artifacts and example code | Via `compute_expression`, `remove_unused_if_branch` | `workspace/code-samples`, `workspace/example`, `workspace/template`, `workspace/test-runner` (per `project.luau:29-33`) | `*.spec.lua*`, `*.story.lua*`, `*.storybook.lua*`, `jest.config.lua*` (per `project.luau:35-40`) | Production plugin releases |

**Important:** `lute run build` without `--channel` defaults to **`prod`**. Docs examples often show `lute run build --channel dev` to keep stories visible.

### Targets

Determine the output platform and API surface. Passed via `--target` flag.

| Target | Default? | Platform | Build Output | Plugin Behavior | Use Case |
|--------|----------|----------|---|---|---|
| `roblox` | **Yes** (`.lute/build.luau:44`) | Roblox Studio plugin | `build/<channel>/roblox/` → `Flipbook.rbxm` | Standard plugin; no internal APIs | Community releases |
| `rotriever` | No | Roblox internal Rotriever registry | `build/<channel>/rotriever/` → `flipbook-core-rotriever/` package bundle | Uses internal Roblox APIs (`_G.INTERNAL_BUILD_TARGET == BuildTarget.Rotriever` badge shown in `FlipbookApp.luau:101`) | Internal Roblox builds; not shipped to Creator Store |

### Subcommands

Determine what gets built. Default is `plugin`.

| Subcommand | What It Builds | Output | Use Case |
|---|---|---|---|
| `plugin` | Main Flipbook plugin binary | `build/<channel>/<target>/Flipbook.rbxm` (synced to Studio plugins dir or custom path) | Standard: `lute run build` or `lute run build --channel dev` |
| `workspace` | Only `flipbook-core` rotriever package | `build/<channel>/<target>/flipbook-core-rotriever/` | Package exports for internal consumption |
| `storybook` | Test storybook place for deployment | `build/flipbook-storybook.rbxl` | For `deploy-storybook` CI workflow |

---

## 4. Build Command Anatomy

```bash
lute run build [subcommand] [options]

# Examples:
lute run build                           # prod plugin, roblox target, sync to Studio
lute run build --channel dev             # dev plugin, keep stories/tests
lute run build --channel dev --watch     # dev, auto-rebuild on changes
lute run build --channel dev --skip-reload # dev, don't reload in Studio
lute run build --target rotriever        # rotriever target, prod channel
lute run build --target rotriever --clean # Full rebuild after dep changes
lute run build storybook                 # Build test storybook place
lute run build --output ~/custom.rbxm    # Build to custom path
lute run build --filter "controls"       # Test build with JEST_TEST_PATH_PATTERN="controls"
```

| Option | Alias | Type | Default | Purpose |
|---|---|---|---|---|
| `--channel` | `-c` | `dev`\|`beta`\|`prod` | `prod` | See Channels table above |
| `--target` | `-t` | `roblox`\|`rotriever` | `roblox` | See Targets table above |
| `--watch` | `-w` | flag | false | Incremental recompile on source changes |
| `--skip-reload` | none | flag | false | Skip Studio plugin reload (only for path matching plugins dir) |
| `--clean` | none | flag | false | Full rebuild; deletes cache |
| `--output` | `-o` | path | `~/.config/Roblox/Plugins/Flipbook.rbxm` (or Windows equivalent) | Custom build output path |
| `--filter` | none | pattern | (none) | Test pattern; sets `JEST_TEST_PATH_PATTERN` for Jest |

---

## 5. User Settings (Runtime)

Settings are persisted in the plugin's local storage (Studio plugin settings API) and read at runtime. Defined in `workspace/flipbook-core/src/UserSettings/defaultSettings.luau`.

| Name | Group | Type | Default | Values / Range | Description | Where Used |
|------|-------|------|---------|---|---|---|
| `rememberLastOpenedStory` | Stories | boolean | `true` | `true`\|`false` | Restore the last-viewed story on plugin open | `workspace/flipbook-core/src/Storybook/useLastOpenedStory.luau:29` checks setting and skips restore if false |
| `theme` | UI | dropdown | `"system"` | `"system"`, `"dark"`, `"light"` | UI theme: match Studio, force dark, or force light | `workspace/flipbook-core/src/Storybook/StoryViewNavbar.luau:77` passes `userSettings.theme` as current dropdown value |
| `sidebarWidth` | UI | number | `260` px | `140`–`500` px (per `constants.luau:6-8`) | Sidebar panel width, persisted across sessions | `workspace/flipbook-core/src/FlipbookApp.luau:98` sets `initialSize` UDim2 from `userSettings.sidebarWidth` |
| `controlsHeight` | UI | number | `200` px | `100`–`400` px (per `constants.luau:10-12`) | Story controls panel height, persisted | `workspace/flipbook-core/src/StoryControls/StoryControlsPanel.luau:31` sets panel `initialSize` UDim2 |
| `collectAnonymousUsageData` | Telemetry | boolean | `true` | `true`\|`false` | Opt in to anonymous usage metrics; user shown opt-in dialog on first open | `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau:13` returns early if false; prevents all telemetry collection |

**Storage mechanism:** `workspace/flipbook-core/src/UserSettings/UserSettingsStore.luau` wraps plugin settings API; persisted to `plugin:GetSetting()` and `plugin:SetSetting()`.

---

## 6. Structural Constants (UI & Layout)

Defined in `workspace/flipbook-core/src/constants.luau`. Not configurable by users but load-bearing for layout.

| Name | Value | Purpose |
|------|-------|---------|
| `STORY_NAME_PATTERN` | `"%.story$"` | Pattern to detect story files (ModuleScript ending in `.story`) |
| `STORYBOOK_NAME_PATTERN` | `"%.storybook$"` | Pattern to detect storybook files |
| `SIDEBAR_INITIAL_WIDTH` | `260` px | Default sidebar width (matches user setting default) |
| `SIDEBAR_MIN_WIDTH` | `140` px | Minimum sidebar width constraint |
| `SIDEBAR_MAX_WIDTH` | `500` px | Maximum sidebar width constraint |
| `CONTROLS_INITIAL_HEIGHT` | `200` px | Default controls panel height |
| `CONTROLS_MIN_HEIGHT` | `100` px | Minimum controls panel height |
| `CONTROLS_MAX_HEIGHT` | `400` px | Maximum controls panel height |
| `SPRING_CONFIG` | `{ clamp = true, mass = 0.6, tension = 700 }` | React Spring animation tuning |
| `FLIPBOOK_RUNTIME_TAG` | `"FlipbookRuntime"` | Tag applied to runtime instances (for detection) |
| `FLIPBOOK_LOGO` | `"rbxassetid://76698965087351"` | Asset ID of Flipbook logo |

---

## 7. Project Configuration (project.luau)

Central repository for paths and semantic constants.

| Name | Value | Purpose |
|------|-------|---------|
| `PROD_CONFIG.prunedDirs` | `{ workspace/code-samples, workspace/example, workspace/template, workspace/test-runner }` | Directories stripped from prod builds via Darklua dead-code elimination |
| `PROD_CONFIG.prunedFiles` | `{ *.spec.lua*, *.story.lua*, *.storybook.lua*, jest.config.lua* }` | File patterns stripped from prod builds |
| `ROBLOX_STORYBOOK_UNIVERSE_ID` | `10262009842` | Roblox universe ID for the public storybook deployment (deploy-storybook) |
| `ROBLOX_STORYBOOK_PLACE_ID` | `139676401890813` | Roblox place ID for the public storybook deployment |

---

## 8. .luaurc Configuration

File: `.luaurc`

| Setting | Value | Purpose |
|---------|-------|---------|
| `languageMode` | `"strict"` | Luau strict type checking enabled for all source files |
| `aliases` (8 total) | See below | Module path aliases for cleaner requires; used throughout codebase |

**Aliases:**
- `@lune` → `~/.lune/.typedefs/0.9.4/` — Lune CLI typedefs
- `@lint` → `~/.lute/typedefs/1.0.0/lint` — Selene lint types
- `@lute` → `~/.lute/typedefs/1.0.0/lute` — Lute CLI types
- `@std` → `~/.lute/typedefs/1.0.0/std` — Luau standard lib types
- `@luaupkg` → `./LuauPackages` — Loom-managed packages
- `@pkg` → `./Packages` — Wally-managed packages
- `@rbxpkg` → `./RobloxPackages` — Roblox CLI packages
- `@repo` → `.` — Repo root (for `project.luau`)
- `@scripts` → `./.lute` — Lute scripts
- `@workspace` → `./workspace` — Workspace members

---

## 9. Asset Configuration (rbxasset.toml)

Creator Store asset metadata and environments.

| Asset | Environment | Type | Name | Model |
|-------|---|---|---|---|
| `assets.prod` | prod | Plugin | Flipbook | Flipbook.rbxm |
| `assets.dev` | prod | Plugin | Flipbook (Dev) | Flipbook.rbxm |
| `assets.smoketest` | prod | Plugin | Flipbook | Flipbook.rbxm |

**Environments:**
- `prod`: Creator ID 1343930 (User), Universe 6599100156, Place 84837374448022

Note: `dev` and `smoketest` also use `environment = "prod"` but are published to different asset IDs via CI workflow.

---

## 10. Toolchain Version Pinning (rokit.toml, wally.toml, loom.config.luau)

### rokit.toml

CLI tools pinned here; run `rokit install` to install all.

| Tool | Version | Purpose |
|------|---------|---------|
| `darklua` | 0.17.1 | String require → Roblox require transform + dead-code elimination |
| `luau-lsp` | 1.60.1 | IDE type server |
| `lune` | 0.9.4 | Luau CLI runtime |
| `lute` | 1.0.0 | Luau project runner (build system) |
| `roblox-packages` | 0.5.0 | Flipbook Labs CLI tools |
| `rocale` | 0.1.3 | Jest cloud runner |
| `rojo` | 7.6.1 | Roblox project sync / packager |
| `selene` | 0.30.1 | Linter |
| `stylua` | 2.3.1 | Code formatter |
| `wally` | 0.3.2 | Package manager |
| `wally-package-types` | 1.5.1 | Wally type definitions |

### wally.toml

Package manager dependencies.

**Runtime:**
- `Charm` 0.11.0-rc.4 — Reactive state management
- `Highlighter` 0.9.0 — Syntax highlighting
- `Log` 0.3.0 — Logging library
- `LuauPolyfill` 1.2.7 — JS polyfills for Luau
- `ModuleLoader` 0.11.0 — Hot-reload module cache bypass
- `React` 17.0.2 (jsdotlua) — React library
- `ReactCharm` 0.4.0-rc.3 — Charm + React integration
- `ReactRoblox` 17.0.2 (jsdotlua) — React renderer for Roblox
- `ReactSpring` 2.0.0 — Animation library
- `sha256` 1.0.1 — Hashing
- `Sift` 0.0.8 — Table utilities
- `Storyteller` 1.12.0 — Story discovery/rendering
- `t` 3.0.0 — Type checking

**Dev:**
- `Fusion` 0.2.0 — Reactive UI library (stories only)
- `Jest` 3.10.0 (jsdotlua) — Test runner
- `JestGlobals` 3.10.0 (jsdotlua) — Jest globals
- `Roact` 1.4.4 — React-like library (stories only)

### loom.config.luau

Loom-managed (non-Wally) dependencies.

| Package | Source | Version |
|---------|--------|---------|
| `flipbook-batteries` | github.com/flipbook-labs/flipbook-batteries | v0.9.0 — Shared Lute utilities |
| `lute` | github.com/luau-lang/lute | v1.0.0 — Build system |
| `dotenv` | github.com/erlcx/lute-dotenv | v0.1.0 — Environment variable loader |

---

## 11. Darklua Configuration (.darklua.json)

Deep dive into how dead-code stripping works for prod builds.

### Process Rules

1. **`convert_require`** — Rewrite Luau string requires (`require("@pkg/foo")`) to Roblox property access (`require(script.Parent.Foo)`), using Rojo sourcemap at `./sourcemap-darklua.json`.

2. **`inject_global_value`** — Inject 8 globals (see section 2); each rule maps an identifier to an environment variable.

3. **Dead-code elimination** (applied in order):
   - `compute_expression` — Simplify constant expressions
   - `remove_unused_if_branch` — Strip branches where condition is a constant (e.g., `if _G.BUILD_CHANNEL == "production" then ... end` becomes `...` in prod)
   - `remove_unused_while` — Strip while loops with constant false condition
   - `filter_after_early_return` — Remove unreachable code after return
   - `remove_nil_declaration` — Strip assignments to nil
   - `remove_empty_do` — Remove empty `do ... end` blocks

This means: if you gate code with `if _G.BUILD_CHANNEL == "production" then`, in prod builds that entire branch is the only one that remains, and in dev builds the gated-out code is completely stripped. This is how `*.story.luau` files disappear from prod.

---

## How to Add a Configuration Axis

### Type A: Environment Variable

1. **Add to `.env.template`** (public contract):
   ```
   MY_NEW_VAR=default_value
   # Brief description of what it controls
   ```

2. **If runtime-needed:** Add to `.darklua.json`:
   ```json
   {
     "rule": "inject_global_value",
     "identifier": "MY_NEW_VAR",
     "env": "MY_NEW_VAR"
   }
   ```

3. **If build-time only:** Read in `.lute/build.luau` via `process.env.MY_NEW_VAR` (no injection needed).

4. **In code:** Access as `_G.MY_NEW_VAR` (runtime) or `process.env.MY_NEW_VAR` (build time).

5. **Document:** Add a row to section 1 and 2 tables above; update re-verification commands.

**Example:** `LOG_LEVEL` is an env var injected globally; `ROBLOX_API_KEY` is build-time only (not injected).

---

### Type B: User Setting

1. **Define in `workspace/flipbook-core/src/UserSettings/defaultSettings.luau`:**
   ```luau
   local myNewSetting: CheckboxSetting = {
     name = "myNewSetting",
     group = SettingGroup.UI,  -- or Stories, or Telemetry
     displayName = "My New Setting",
     description = "What it does",
     settingType = SettingType.Checkbox,
     value = true,  -- default
   }

   local settings = {
     myNewSetting = myNewSetting,
     -- ... rest
   }
   ```

2. **Export type:** Update `export type Settings = typeof(settings)`.

3. **Access at runtime:** Via `UserSettingsStore.get().getStorage().myNewSetting`.

4. **UI:** Settings panel auto-renders based on `group` and `settingType`; dropdown choices render from `choices` table.

5. **Document:** Add row to section 5 table; cite the file.

**Example:** `collectAnonymousUsageData` is a checkbox setting; `theme` is a dropdown.

---

### Type C: Structural Constant (Unchangeable)

1. **Define in `workspace/flipbook-core/src/constants.luau`:**
   ```luau
   MY_NEW_CONSTANT = "value",
   ```

2. **Use throughout code:** `local constants = require("@root/constants"); constants.MY_NEW_CONSTANT`.

3. **Document:** Add row to section 6 table.

**Example:** `SIDEBAR_INITIAL_WIDTH = 260`.

---

### Type D: Build Channel / Target Gating

1. **Sentinel:** Wrap code in `if _G.BUILD_CHANNEL == BuildChannel.Production then ... end` or similar.

2. **Darklua strips automatically:** Dead-code elimination removes non-matching branches.

3. **Document in AGENTS.md or change control skill** (not here).

**Example:** `FlipbookApp.luau:99-101` shows dev/beta/internal badges only in non-prod builds.

---

### Type E: Project Constant (project.luau)

1. **Add to `project.luau` return table:**
   ```luau
   MY_CONSTANT = "value",
   ```

2. **Access in build scripts:** `local project = require("@repo/project"); project.MY_CONSTANT`.

3. **Document:** Add row to section 7 table; cite usage.

**Example:** `PROD_CONFIG.prunedDirs` lists directories stripped from prod.

---

## Re-Verification Commands

Run these periodically to catch drift (as of 2026-07-01):

```bash
# Section 1: Env vars in .env.template
grep "^[A-Z_]*=" .env.template | sort

# Section 2: Darklua injected globals
jq '.process[] | select(.rule == "inject_global_value") | .identifier' .darklua.json | sort

# Section 2 (detail): All places where _G. is used in source
grep -r "_G\." workspace/flipbook-core/src --include="*.luau" | grep -v "build/\|.spec\|.story" | wc -l
# Should be ~20+ (build globals read in logger, about, telemetry, feedback)

# Section 3: Build channels and targets (verify options in build.luau)
grep -A5 'channel == "dev" or channel == "beta"' .lute/build.luau

# Section 5: User settings defined
grep -E '^\s*(rememberLastOpenedStory|theme|sidebarWidth|controlsHeight|collectAnonymousUsageData)' workspace/flipbook-core/src/UserSettings/defaultSettings.luau

# Section 5: Settings reads in code
grep -r "userSettings\." workspace/flipbook-core/src --include="*.luau" | cut -d: -f2 | sort -u | head -20

# Section 6: Constants defined
grep "^[[:space:]]*[A-Z_]* =" workspace/flipbook-core/src/constants.luau

# Section 7: project.luau structure
grep -E '(PROD_CONFIG|STORYBOOK|ROBLOX)' project.luau

# Section 8: Luau aliases
jq '.aliases | keys[] as $k | "\($k): \(.[$k])"' .luaurc

# Section 9: rbxasset environments
grep "^\[assets\.\|^\[environments\." rbxasset.toml

# Section 10: Tool versions (rokit.toml)
grep -E "^[a-z-]+ =" rokit.toml

# Section 10: Wally deps
grep -E "^[A-Z][a-zA-Z]+ =" wally.toml | head -20

# Section 10: Loom deps
jq '.package.dependencies | keys[]' loom.config.luau

# Candidate issue: Check if ENABLE_OUTPUT_LOGGING is actually injected or if code is stale
grep "ENABLE_OUTPUT_LOGGING" .darklua.json
# (Should return the inject rule; if not, check logger.luau logic)
```

---

## Known Issues & Candidates

1. **JEST_TEST_PATH_PATTERN drift:** Passed via `--filter` to build, but not in `.env.template`. Verify it's documented in test runbook (see `flipbook-validation-and-qa` skill).

2. **`rbxasset.toml` asset IDs:** Asset IDs for dev (nightly 88523969718241) and smoketest versions live in CI, not in `.toml`. Sync with release workflow.

---

## Provenance & Maintenance

- **Last verified:** 2026-07-01 by reading `.env.template`, `.darklua.json`, `project.luau`, `.luaurc`, `workspace/flipbook-core/src/UserSettings/defaultSettings.luau`, `workspace/flipbook-core/src/constants.luau`, `rokit.toml`, `wally.toml`, `loom.config.luau`, `rbxasset.toml`, and grepping `_G.` usage in source.
- **To update:** Re-run re-verification commands; any new vars, settings, or constants will appear immediately.
- **Archive:** Known FIXMEs in code (none currently flagged as config-related).
