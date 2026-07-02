---
name: flipbook-architecture-contract
description: Load-bearing design decisions, invariants, and known weak points of Flipbook's architecture. Use when understanding or extending system design, debugging architectural mismatches, or validating deep changes (PR #582 embedding, controls refactor, state management, build pipeline, plugin vs. embedded modes).
---

# Flipbook Architecture Contract

This skill documents the foundational design decisions, architectural invariants, and known weak points that shape Flipbook's codebase. It is the reference for understanding why things are structured the way they are and what constraints must hold for the system to function correctly.

## I. The Thin-Shell Bootstrap Contract

**The invariant:** Root `/src/` contains only three thin starter scripts (plugin, embedded client, embedded server). All real application logic lives in `workspace/flipbook-core/src/`. This separation enables embedding without duplicating code.

### The Three Starter Scripts

1. **`src/PluginStarterScript.plugin.luau`** — Studio plugin bootstrap. Creates toolbar button, dock widget, and calls `FlipbookCore.createFlipbookPlugin()`. This is the only file with access to the true `plugin` object.
2. **`src/EmbeddedClientStarterScript.client.luau`** — Embedded runtime client. Checks for `PluginDebugService` to escape if plugin-debugged, then calls `FlipbookCore.createEmbeddedFlipbookApp()` with a ScreenGui.
3. **`src/EmbeddedServerStarterScript.server.luau`** — Embedded runtime server. Disables `CharacterAutoLoads` to prevent player respawns interfering with UI rendering. Minimal initialization.

**Why this split?** The plugin and embedding modes have different execution contexts (Studio vs. game client), different capabilities (plugin object vs. Players service), and different security contexts (plugin permissions vs. game-client-script permissions). By keeping starter scripts thin, both modes reuse the same `flipbook-core` application logic.

**Invariant assertion:** No business logic may exist in `/src/`. Only imports, setup, and delegation to `flipbook-core`. Verify by checking: `wc -l src/*.luau` should be under 100 lines per script; no Storybook, Sidebar, or TreeView logic should exist there.

---

## II. The Pluginlike Abstraction & Embedding Decoupling

**The invariant:** Flipbook depends on an abstract `Pluginlike` type, not the concrete Roblox `plugin` object. This enables embedding (PR #582).

### Pluginlike Type Contract

Location: `workspace/flipbook-core/src/Common/types.luau`

```luau
export type Pluginlike = {
  GetMouse: (self: Pluginlike) -> PluginMouse,
  GetSetting: (self: Pluginlike, settingName: string) -> unknown,
  OpenScript: (self: Pluginlike, script: LuaSourceContainer, lineNumber: number?) -> (),
  SetSetting: (self: Pluginlike, settingName: string, value: unknown) -> (),
}
```

**Four required methods:**
- `GetMouse()` — Needed for cursor icon (dev only); embedded mode provides a stub returning `{ Icon = "" }`.
- `GetSetting() / SetSetting()` — User settings persistence (sidebar width, pinned storybooks, opt-in telemetry status). Both modes support this via `Plugin.GetSetting` or `LocalStorageStore` wrapper.
- `OpenScript()` — Click-to-open story file in Editor (plugin mode only); embedded mode is a no-op.

### createFlipbookApp vs. createFlipbookPlugin

**`createFlipbookApp(container, options?)`** — The core app factory. Takes a GUI container and optional parameters.

Location: `workspace/flipbook-core/src/createFlipbookApp.luau`

```luau
export type Options = {
  plugin: Pluginlike?,          -- abstract plugin (not required for embedded)
  overlayGui: GuiBase2d?,        -- overlay target for dialogs
  mode: AppMode?,                -- PluginWidget, EmbeddedClient, or unset
}
```

Returns: `{ mount, unmount, destroy }` lifecycle functions.

**Key design:** `createFlipbookApp` is mode-agnostic. It:
1. Creates a React root in the container
2. Wraps the app in `ContextProviders` (passing `plugin` and `overlayGui`)
3. Renders `FlipbookApp` component with the mode
4. Returns mount/unmount/destroy lifecycle handlers

**`createFlipbookPlugin(plugin, widget, button?)`** — Plugin-specific wrapper.

Location: `workspace/flipbook-core/src/Plugin/createFlipbookPlugin.luau`

Adds:
- Toolbar button toggle (maps button clicks to widget visibility)
- Lazy mount/unmount on widget visibility changes (performance optimization)
- Connection cleanup on plugin unload

**`createEmbeddedFlipbookApp(screenGui)`** — Embedded-specific wrapper.

Location: `workspace/flipbook-core/src/Embedding/createEmbeddedFlipbookApp.luau`

Adds:
- No toolbar or dock widget (uses ScreenGui directly)
- Immediately mounts (no lazy loading)
- No toggleable visibility (always-on once deployed)

### Invariant: Pluginlike Contract Must Hold

Any code accessing plugin functionality must:
1. Use only the four Pluginlike methods (never `plugin.CreateDockWidgetPluginGui`, `plugin.Name`, etc.)
2. Handle the plugin being nil gracefully (defaultPlugin stub provided in `createFlipbookApp` lines 20–31)

**Verification command:** `grep -r "plugin:" workspace/flipbook-core/src --include="*.luau" | grep -v "Pluginlike\|GetMouse\|GetSetting\|SetSetting\|OpenScript" | wc -l` should return 0 (no unauthorized plugin method calls).

---

## III. Layering Contract: Flipbook ← Storyteller ← ModuleLoader

**The invariant:** Three-layer dependency graph. Flipbook uses Storyteller (story discovery/rendering); Storyteller uses ModuleLoader (module hot-reload). Each layer owns a specific concern; layers must not skip intermediates or reach around.

```
┌─────────────────────────────┐
│ Flipbook                    │ (story selection UI, control panels, tree view)
│ ├─ Storybook/              │ (story selection, filtering, error handling)
│ ├─ StoryControls/          │ (control schema UI, state management)
│ └─ TreeView/               │ (DataModel hierarchy + story tree)
└──────────────┬──────────────┘
               │ requires
┌──────────────v──────────────┐
│ Storyteller (Wally dep)     │ (story discovery, loading, rendering)
│ ├─ loadStoryModule()        │ (parse story format, validate schema)
│ ├─ loadStorybookModule()    │ (parse storybook format)
│ ├─ createRendererForStory() │ (dispatch to React/Roact/Fusion/etc.)
│ └─ render()                 │ (mount story to container)
└──────────────┬──────────────┘
               │ requires
┌──────────────v──────────────┐
│ ModuleLoader (Wally dep)    │ (require cache bypass, hot reload)
│ ├─ weak-key registry        │ (GC module on source change)
│ ├─ loadstring-based loading │ (fresh eval, not Roblox require)
│ └─ change detection         │ (via Source property watch)
└─────────────────────────────┘
```

### Layer Ownership

**ModuleLoader layer:**
- Owns: Module source caching, hot-reload detection, fresh require evaluation
- Must provide: `ModuleLoader.new(fsService)`, `load(moduleName)`, `unload(moduleName)`, change subscription
- Constraint: Must NOT know about story format, control schemas, or rendering

**Storyteller layer:**
- Owns: Story/Storybook file format parsing, story discovery, renderer dispatch, rendering lifecycle
- Must provide: `loadStoryModule(loader, module)`, `loadStorybookModule(loader, module)`, `render(story, container)`
- Constraint: Must NOT know about Flipbook UI panels, control panel state, or plugin-specific features. Must NOT bypass ModuleLoader to access source.

**Flipbook layer:**
- Owns: Story selection UI, sidebar tree, control state management, telemetry
- Must provide: UI components, navigation, settings persistence
- Constraint: Must NOT modify Storyteller's story format or discovery logic. Must NOT call ModuleLoader directly. Must NOT modify story source (read-only to user code).

### Invariant: No Reaching Around Layers

**Anti-pattern 1:** Flipbook directly accessing `ModuleLoader` (should go through Storyteller).
**Anti-pattern 2:** Storyteller directly accessing Roblox filesystem (should use ModuleLoader).
**Anti-pattern 3:** Flipbook mutating Storyteller's internal state (should use getters/subscriptions).

**Verification command:** Search for layer violations:
```bash
grep -r "ModuleLoader" workspace/flipbook-core/src --include="*.luau" | grep -v "packages\|Wally" | wc -l
# Should be 0 (ModuleLoader only used by Storyteller, which is a Wally dep)
```

---

## IV. Charm Signal Stores as the State Pattern

**The invariant:** All application state flows through Charm signal stores. This enables reactive updates, computed dependencies, and per-component subscriptions without re-render overhead.

### Why Charm Over Alternatives

**Background:** Flipbook originally used Roblox Signals; PR #509 migrated to Charm (community signal library).

**Rationale for Charm:**
- **Computed signals** — derived state auto-updates when dependencies change
- **Untracked access** — read state without triggering subscriptions (useful in loops or destructors)
- **Minimal API surface** — simpler than Roact/Redux, no boilerplate

**Trade-off accepted:** Charm's immutability flag (`Charm.flags.frozen`) is disabled due to storyteller/issues/100 (Storyteller mutates state). See Known Weak Points (Section VI).

### Store Pattern in Flipbook

**Core stores:**

1. **`createStoryControlsStore(schema)`** — Per-story control state. Location: `workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau`
   - Signals: one per control (Boolean, Number, String, etc.)
   - Computed: `getControls()` merges schema defaults + overrides
   - Subscription: Only re-render control Row whose value changed (via `useSignalState()` per-control)

2. **`UserSettingsStore`** — Plugin settings (sidebar width, pinned storybooks). Location: `workspace/flipbook-core/src/UserSettings/UserSettingsStore.luau`
   - Signals: sidebar width, pinned instances, telemetry opt-in status
   - Persistence: backed by `plugin.GetSetting() / SetSetting()`

3. **`createPluginStore()`** — Aggregated plugin state. Location: `workspace/flipbook-core/src/Plugin/PluginStore/init.luau`
   - Computed: derives from UserSettingsStore
   - Provides: single entry point for plugin-level state

4. **`createTreeNodeStore()`** — TreeView node state. Location: `workspace/flipbook-core/src/TreeView/createTreeNodeStore.luau`
   - Signals: per-node (name, icon, selected, expanded, visible, filtered, pinned, instance)
   - Computed: ancestors, descendants, path, leaf nodes, selected descendants
   - Constraint: Untracked access in loops (line 86: `Charm.untracked(getDescendants)`) prevents subscription thrashing

### Invariant: All Mutable State Must Flow Through Stores

**Anti-pattern:** Using React `useState` for app-level state that other components need to observe.

**Correct pattern:** Use Charm stores + React context binding. Example from `StoryControlsContext.luau`:

```luau
local StoryControlsContext = React.createContext(nil)
-- Provider wraps app with: StoryControlsContext.Provider { value = store }
-- Consumers read store via: React.useContext(StoryControlsContext)
```

**Verification command:** Check store creation is centralized:
```bash
grep -r "Charm.signal\|Charm.computed" workspace/flipbook-core/src --include="*.luau" | wc -l
# Should be ~20–30 (concentrated in store files, not components)
```

---

## V. Darklua Build Contract: String Requires → Roblox Requires

**The invariant:** Source code uses Luau-style string requires (`require("@pkg/Charm")`); build output uses Roblox property-access requires (`require(script.Parent.Charm)`). Darklua performs this transformation; never hand-edit build output.

### Source Style

Source code uses string aliases (verified in `.luaurc`):

```luau
-- src/ and workspace/ files
local React = require("@pkg/React")              -- Wally package
local Storyteller = require("@pkg/Storyteller")  -- Wally package
local logger = require("@root/logger")           -- workspace/flipbook-core/src/logger.luau
local Charm = require("@pkg/Charm")              -- Wally package
local Common = require("@workspace/flipbook-core/src/Common")
```

Aliases defined in `.luaurc`:
- `@pkg/` → Wally packages in `Packages/`
- `@workspace/` → workspace members (e.g., flipbook-core)
- `@root/` → workspace/flipbook-core/src/
- `@repo/` → repo root (project.luau, etc.)
- `@scripts/`, `@lute/`, `@std/`, `@lune/` — Lute utilities

### Build Pipeline

```
source (.luau with string requires)
  ↓
Darklua 0.17.1 (via .darklua.json)
  ├─ convert_require: rewrite @pkg/*,@root/* to property access
  ├─ inject_global_value: BUILD_VERSION, BUILD_CHANNEL, BUILD_HASH, BUILD_TARGET, BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING, JEST_TEST_PATH_PATTERN
  └─ dead-code elimination: compute_expression, remove_unused_if_branch, remove_empty_do
  ↓
build/<channel>/<target>/ (.lua with Roblox require() calls)
  ↓
Rojo (via sourcemap.json and sourcemap-darklua.json)
  ├─ converts .lua to binary instances (ModuleScript, LocalScript, etc.)
  └─ verifies require() calls resolve to correct scripts
  ↓
Flipbook.rbxm or rotriever bundle
```

### Invariant: Never Hand-Edit Build Output

The build cache (`build/build-cache.json`) tracks workspace-member hashes. If you edit `build/` directly:
1. Incremental builds won't detect changes (cache thinks file hasn't changed)
2. Next rebuild overwrites your changes
3. If build cache is deleted, all files rebuild from source (no way to preserve hand-edits)

**Verification command:** Confirm no stale build artifacts exist:
```bash
ls -la /Users/marin/Code/flipbook/build/build-cache.json && echo "Cache found (expected)"
grep '"hash":' /Users/marin/Code/flipbook/build/build-cache.json | wc -l
# Should match number of workspace members (~7)
```

### Dead-Code Elimination via Build Channels

Darklua's `compute_expression` + `remove_unused_if_branch` rules enable channel-gated code:

```luau
-- source
if _G.BUILD_CHANNEL == "development" then
  local storybook = require("./example.story")
  -- This branch is REMOVED in prod builds
end
```

**Prod build:** Example story file never packaged into .rbxm (no Rojo need to include it).

**Dev build:** Story file included; tests run.

**Configuration:** `project.luau` `PROD_CONFIG.prunedDirs` and `prunedFiles` define what Darklua strips. Currently prunes:
- `workspace/code-samples/`, `workspace/example/`, `workspace/template/`, `workspace/test-runner/` (entire dirs)
- `*.spec.lua*`, `*.story.lua*`, `*.storybook.lua*`, `jest.config.lua*` (file patterns)

**Invariant:** All channel/target checks must be compile-time constants (`_G.BUILD_CHANNEL == "prod"`, not variables). Darklua cannot optimize dynamic conditionals.

---

## VI. Embedding Architecture: Three Starter Scripts, Lower Security Context

**The invariant:** Embedding delivers Flipbook as three LocalScripts (client, server, optional server script) + Flipbook runtime (Folder tagged with `FLIPBOOK_RUNTIME_TAG`). These run at game-client-script privilege level (no plugin APIs, limited Roblox access).

### Embedded Starter Scripts

1. **`EmbeddedClientStarterScript.client.luau`** — Player-side initialization.
   - Exits if `PluginDebugService` ancestor detected (prevents double-init in plugin debug mode)
   - Creates ScreenGui in PlayerGui
   - Calls `FlipbookCore.createEmbeddedFlipbookApp(screenGui)`

2. **`EmbeddedServerStarterScript.server.luau`** — Server-side setup.
   - Sets `Players.CharacterAutoLoads = false` (prevents respawns interfering with UI)
   - Minimal; most work is client-side

### Embedding Routes

**Route 1 — "Embed into Experience" dialog:** User clicks dialog in Flipbook UI → embedded copies self to selected DataModel location.

Location: `workspace/flipbook-core/src/Embedding/EmbedIntoExperienceDialog.luau`

Calls: `embedFlipbookRuntime(target)` which clones the Flipbook runtime folder, tags it with `FLIPBOOK_RUNTIME_TAG`, and parents it to target.

**Route 2 — flipbook-cli:** Deploys pre-built Flipbook.rbxm to experience via Open Cloud.

Location: `/Users/marin/Code/deploy-storybook` (sibling repo)

Unpacks .rbxm, injects as LocalScript pair, and publishes place.

### Invariant: FLIPBOOK_RUNTIME_TAG Uniqueness

Only one embedded Flipbook may run per experience (prevents UI layering bugs). `createEmbeddedFlipbookApp` enforces:

```luau
local existing = CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)
if #existing > 0 then
  for _, instance in existing do
    instance:Destroy()  -- destroy old instances before creating new
  end
end
```

Verify: `grep "FLIPBOOK_RUNTIME_TAG" /Users/marin/Code/flipbook/workspace/flipbook-core/src/constants.luau` shows value.

### Known Weak Point: HTTP Proxy for Embedded HTTP Requests

**Status:** Open branch `embedded-http-proxy` (75 commits, 2026-06-19, stalled). Embedded scripts have no direct HTTP access (cannot call `HttpService:GetAsync()` from client context).

**Issue:** Embedded Flipbook cannot reach backend telemetry, update checks, or external APIs.

**Partial solution:** Embedded scripts could use proxy server; unclear if architecture decision has been finalized.

**Impact:** Embedded telemetry may be incomplete; backend visibility limited to what game servers report.

---

## VII. Build Channels & Prod Pruning Invariants

**The invariant:** Two build channels (dev, prod) + one target (roblox, rotriever). Channels control what gets packaged; targets control output format.

### Channels

| Channel | Keeps Dev Files? | Use Case |
|---------|------------------|----------|
| `dev` | ✓ Tests, stories, code samples | Plugin development, CI integration tests |
| `prod` | ✗ Strips per PROD_CONFIG | Creator Store release, nightly plugin |

**Default:** `lute run build` defaults to `prod` (use `--channel dev` for dev).

### Prod Pruning

`project.luau` `PROD_CONFIG`:

```luau
prunedDirs = {
  "./workspace/code-samples",
  "./workspace/example",
  "./workspace/template",
  "./workspace/test-runner",
},
prunedFiles = {
  "*.spec.lua*",
  "*.story.lua*",
  "*.storybook.lua*",
  "jest.config.lua*",
}
```

Darklua's dead-code elimination combines with Rojo: if a file is excluded from the source map, Rojo doesn't package it.

**Invariant:** Test/story files must be gated behind compile-time BUILD_CHANNEL checks if used in source (otherwise pruned files cause "required module not found" errors in prod).

### Targets

| Target | Output | Use |
|--------|--------|-----|
| `roblox` | `.rbxm` (binary, Rojo-packaged) | Plugin, embedding |
| `rotriever` | Flat Luau + metadata | Internal Rotriever package registry |

---

## VIII. Known Weak Points & Admitted Debt

### 1. Charm.flags.frozen Workaround (Critical, Unresolved)

**Location:** `src/PluginStarterScript.plugin.luau` lines 16–31

**Issue:** Storyteller mutates state despite Charm's immutability promise (storyteller/issues/100).

**Workaround:** `Charm.flags.frozen = false` disables immutability checks.

**Impact:** State mutations may corrupt Charm's signal graph in edge cases; edge cases have not materialized in practice, but the risk remains.

**Re-verification:** No attempt to re-enable immutability (do not remove the workaround).

**Upstream dependency:** Requires Storyteller refactor; community issue open but unfixed for 6+ months.

### 2. TreeView setSortOrder Cast to `any` (Type System Weakness)

**Location:** `workspace/flipbook-core/src/TreeView/createTreeNodeStore.luau` lines 74–81

**Issue:** Luau's type system infers `setSortOrder` (a Charm setter) as accepting either a value or an update function. Since we want to store a function (the sort comparator), type inference fails.

**Workaround:** Cast `sort` to `any` before passing to signal setter.

**Impact:** Reduces type safety for sort order mutations; unverified if other callers are type-safe.

**Re-verification command:** `grep -A 3 "setSortOrder" workspace/flipbook-core/src/TreeView/createTreeNodeStore.luau`

### 3. CheckControl Grid Layout TODO

**Location:** `workspace/flipbook-core/src/StoryControls/ControlElements/CheckControl.luau` line 41

**Issue:** Checkboxes render as vertical stack; should be grid for many items.

**Impact:** Poor UX for control schemas with 10+ check items (horizontal scrolling/overflow).

**Nice-to-have:** Foundation components support grid; low priority.

### 4. Storybook/types.luau Optional Fields

**Location:** `workspace/flipbook-core/src/Storybook/types.luau` line 11

**Issue:** Some Storybook type fields marked optional (`?`) but conceptually required.

**Impact:** Type safety; authors can create invalid storybooks that pass type check.

**Candidate fix:** Mark required fields as such; use validators in Storyteller schema parsing.

### 5. ContextProviders Error Handling in Tests

**Location:** `workspace/flipbook-core/src/createFlipbookApp.luau` line 43

**Comment:** "ContextProviders having an error won't fail tests. We really need a smoketest for this file"

**Issue:** React.createElement wrapping ContextProviders doesn't propagate errors to test runner.

**Impact:** ContextProvider bugs (e.g., NavigationContext not initialized) pass test suite silently.

**Candidate fix:** Add integration test mounting ContextProviders in real React tree.

### 6. React Render Bug Workaround (stories.spec.luau)

**Location:** `workspace/flipbook-core/src/stories.spec.luau` line 30

**Issue:** React render order issue; workaround applied via explicit yield.

**Unresolved:** Root cause unclear; workaround is a band-aid.

### 7. ControlGroup & Object Migration (UI Labs Compat)

**Location:** Storyteller migration code (external dependency)

**Issue:** UILabs.ControlGroup nesting flattens silently in migration; UILabs.Advanced.Object type not supported (returns nil).

**Impact:** UILabs story authors see control groups disappear; Object controls omitted.

**Status:** uilabs-controls-support branch stalled (May 9 2026). See the flipbook-story-controls-campaign skill for the current plan and ranked options.

---

## IX. Invariants as Testable Assertions

Each invariant below can be verified via a command or test.

### I-1: Root src/ Contains Only Thin Bootstraps

```bash
# Assertion: no business logic in src/
# Re-verify: grep for Storybook, TreeView, StoryControls imports
grep -r "Storybook\|TreeView\|StoryControls" /Users/marin/Code/flipbook/src --include="*.luau" | wc -l
# Expected: 0
```

### I-2: Pluginlike Contract Holds

```bash
# Assertion: no unauthorized plugin method calls
grep -r "plugin\." workspace/flipbook-core/src --include="*.luau" \
  | grep -v "plugin:GetMouse\|plugin:GetSetting\|plugin:SetSetting\|plugin:OpenScript\|Pluginlike" \
  | wc -l
# Expected: 0
```

### I-3: No ModuleLoader Direct Calls

```bash
# Assertion: ModuleLoader only used by Storyteller (Wally dep)
grep -r "ModuleLoader" workspace/flipbook-core/src --include="*.luau" \
  | grep -v "Packages\|Wally" | wc -l
# Expected: 0
```

### I-4: All State Flows Through Charm Stores

```bash
# Assertion: React useState used sparingly, not for app state
grep -r "React.useState" workspace/flipbook-core/src --include="*.luau" \
  | head -5
# Spot-check: usage should be for temporary component state (e.g., loading, modal open), not shared state
```

### I-5: Build Output Never Hand-Edited

```bash
# Assertion: build-cache.json tracks all workspace members
wc -l /Users/marin/Code/flipbook/build/build-cache.json
# Expected: >200 (cache entry per file + metadata)
```

### I-6: Dead-Code Elimination Works

```bash
# Assertion: prod build excludes test files
grep -r "\.spec\." build/prod/roblox/workspace/ 2>/dev/null | wc -l
# Expected: 0
```

### I-7: FLIPBOOK_RUNTIME_TAG Uniqueness Enforced

```bash
# Assertion: only one embedded runtime may exist
grep -B 5 "CollectionService:GetTagged(constants.FLIPBOOK_RUNTIME_TAG)" \
  workspace/flipbook-core/src/Embedding/embedFlipbookRuntime.luau
# Expected: destroy loop visible (lines 9–14)
```

---

## X. Provenance and Maintenance

**Last verified:** 2026-07-01

**Re-verification steps:**

1. **Pluginlike contract integrity** (quarterly):
   ```bash
   grep "type Pluginlike" workspace/flipbook-core/src/Common/types.luau && \
   grep "Pluginlike\|plugin:" src/PluginStarterScript.plugin.luau | head -5
   ```

2. **Charm.frozen workaround still present** (never remove without resolving storyteller/issues/100):
   ```bash
   grep "Charm.flags.frozen = false" src/PluginStarterScript.plugin.luau
   ```

3. **Build channels & prod pruning active** (before each release):
   ```bash
   lute run build --channel prod && \
   find build/prod/roblox -name "*.spec.lua*" | wc -l  # must be 0
   ```

4. **Embedding route still works** (before embedding-related PRs):
   ```bash
   grep "embedFlipbookRuntime\|createEmbeddedFlipbookApp" workspace/flipbook-core/src --include="*.luau" | wc -l
   # Expected: 3+ (EmbedIntoExperienceDialog, createEmbeddedFlipbookApp, init)
   ```

5. **Known weak points unchanged** (document any resolution):
   ```bash
   git log --oneline --all -- storyteller/issues/100 workspace/flipbook-core/src/TreeView/createTreeNodeStore.luau | head -1
   # Confirms no fix attempt
   ```

**Related skills:** flipbook-build-and-toolchain, flipbook-domain-reference, flipbook-story-controls-campaign, flipbook-debugging-playbook

**Related docs:** AGENTS.md (project overview), flipbook-docs branch (architecture.md, module-loader.md, story-container.md)
