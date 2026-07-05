---
name: flipbook-validation-and-qa
description: "Acceptance discipline: what counts as proof a change works, test anatomy, spec-writing guide. Use when: you need to prove a fix is correct (learn the evidence bar), writing unit tests, adding specs to a PR, or understanding why a test matters. Three tiers of validation: Lint (static checks) → Analyze (type safety) → Test (behavior in real Roblox). For measurement/instrumentation to *find* the bug, see flipbook-diagnostics-and-tooling."
type: process
---

# Flipbook Validation & QA

This skill describes the three validation tiers, what they prove and cannot prove, the test inventory, how to write specs, what counts as evidence, and honest fallback when cloud tests cannot run. **Scope:** What counts as evidence and how to add tests; validation standards and acceptance discipline.

## When NOT to use this skill

Use `flipbook-change-control` (sibling 1) for PR gating rules and non-negotiables. Use `run-flipbook-checks` (under `.agents/skills/`) for quick command reference (lint, analyze, test). Use `flipbook-debugging-playbook` for symptom→triage when a test fails. Use `flipbook-diagnostics-and-tooling` to measure/instrument and find bugs.

## The Three Validation Tiers

Flipbook uses three layered validation gates that build on each other. Each has specific power and known limits.

### Tier 1: Lint (Selene + StyLua)

**What it proves:** Style compliance, dead code, missing requires, typos in identifiers — the low-hanging fruit caught by static linters.

**Command:**
```bash
lute run lint
```

**What it checks:**
- Selene (`std = "roblox"`, `global_usage = "allow"`)
- StyLua with `sort_requires = true`
- Markdown formatting (via Prettier)
- No `.lua` files; only `.luau` allowed (enforced via Selene)

**What it CANNOT catch:** Runtime errors, logic bugs, type violations (Tier 2), behavior in a real DataModel (Tier 3).

**When to use:** Every PR should pass lint before touching analyze/test. A lint failure blocks merging.

---

### Tier 2: Analyze (Luau strict type checking)

**What it proves:** Type violations, unused locals, incorrect function signatures, schema mismatches — all violations of strict Luau semantics.

**Command:**
```bash
lute run analyze
```

**How it works:**
- Runs `luau-lsp` in strict mode (`.luaurc` sets `"languageMode": "strict"`)
- Requires `lune setup` and `lute setup` before first run (handled by CI)
- Checks all workspace members and build outputs
- Injects aliases (`@pkg/`, `@repo/`, `@workspace/`, etc.) from `.luaurc`

**What it CANNOT catch:** Behavioral bugs that are type-correct (off-by-one, wrong control flow), visual regressions, rendering bugs, Studio-only interactions, Runtime exceptions from Roblox APIs.

**When to use:** Every PR should pass analyze. A type error indicates the fix is incomplete or incorrectly shaped.

---

### Tier 3: Test (Jest in Roblox via Cloud Luau Execution)

**What it proves:** Behavior in a real Roblox DataModel with actual Instances, Signals, and Roblox APIs available. Tests are the only place where rendering, component lifecycle, hooks, and store subscriptions are validated.

**Command:**
```bash
lute run test
lute run test --filter "PatternString"
lute run test --apiKey "YOUR_KEY"
```

**How it works:**
- Builds dev plugin (`lute run build plugin --channel dev --clean --skip-reload`)
- Packs a test place via Rojo (loads built plugin into ReplicatedStorage)
- Runs jsdotlua Jest in the cloud via Rocale/Luau Execution API
- Test runner entry: `.lute/tasks/run-tests.luau` → `workspace/test-runner/src/init.luau`
- Jest config: `workspace/flipbook-core/src/jest.config.luau` with `testMatch = { "**/*.spec" }`
- Globals injected by Darklua: `_G.JEST_TEST_PATH_PATTERN` (set by `--filter`)
- Test place ID: `ROBLOX_UNIT_TESTING_PLACE_ID=123506190725771` (universe `6599100156`)

**Requires:** `ROBLOX_API_KEY` in `.env` or `--apiKey` flag (from Open Cloud).

**What it CANNOT catch:**
- **Visual regressions:** Tests render into Instances, not screenshot pixels. A color, font size, or layout change is invisible to Jest unless explicitly asserted (rare).
- **Studio-only interactions:** Plugin hot-reload, script debugger integration, .rbxm file sync, Explorer drag-drop.
- **ContextProvider errors:** Known FIXME in `createFlipbookApp.luau` (grep `FIXME: ContextProviders having an error won't fail tests`) — if a ContextProvider throws, tests do not fail (React error boundaries capture it; the test sees an empty tree and passes). This is a gap; a manual smoke-test is required (see "Honest Fallback" below).

**When to use:** Always when possible. A passing test is the strongest evidence a fix works. A failing test that passes after a change is definitive proof of correctness.

---

## Test Inventory (as of 2026-07-01)

### Spec Files: 16 total

Count by `find workspace/flipbook-core/src -name "*.spec.luau" | wc -l`.

| File | Lines | Coverage |
|------|-------|----------|
| `FlipbookApp.spec.luau` | 71 | App mount/lifecycle |
| `stories.spec.luau` | 69 | Every-story smoke test; all 49 stories render without error |
| `createStoryControlsStore.spec.luau` | 71 | Store defaults, overrides, signal identity, getControls() flattening |
| `createTreeNodeStore.spec.luau` | ~50 | Tree node store mutations |
| `createPluginSettingsStore.spec.luau` | ~40 | Plugin settings store |
| `renderHook.spec.luau` | ~30 | React hook testing utility |
| `newFolder.spec.luau` | ~20 | Instance creation helper |
| `usePrevious.spec.luau` | 66 | Hook: previous value tracking |
| `useZoom.spec.luau` | ~40 | Hook: zoom state |
| `getInstanceFromPath.spec.luau` | ~30 | Path resolution |
| `useThemeName.spec.luau` | ~20 | Hook: theme name |
| `getInstanceFromFullName.spec.luau` | ~30 | Full name parsing |
| `mapRanges.spec.luau` | ~20 | Numeric range mapping |
| `getInstancePath.spec.luau` | ~30 | Path generation |
| `useEvent.spec.luau` | ~40 | Hook: event listening |
| `createPinnedInstanceStore.spec.luau` | ~40 | Pinned instance store |

### Story Files: 49 total (validation artifacts, not unit tests)

Count by `find workspace -name "*.story.luau" | wc -l`.

Stories are colocated with source and serve as smoke tests. `stories.spec.luau` iterates all 49 stories and verifies each mounts and unmounts without crashing.

**Notable gaps in spec coverage (dirs with zero .spec.luau files):**
- `About/` — AboutView, RobloxProfile stories exist but untested
- `Embedding/` — Core embedding feature; no spec
- `Enums/` — Enum definitions; no spec (not behavior-critical)
- `Feedback/` — DiscardChangesDialog, FeedbackDialog, SuccessDialog stories exist but untested
- `Http/` — HTTP client; no spec
- `Logs/` — LogsView story exists but untested
- `Navigation/` — Navigation state; no spec
- `Panels/` — Sidebar, Topbar, ResizablePanel stories exist but untested
- `Permissions/` — Permission checking; no spec
- `Plugin/PluginStore/` — Plugin state; spec exists at parent
- `StoryControls/ControlElements/` — 11 control UI components (Boolean, Check, Color, Date, MultiSelect, Number, Object, Radio, Select, Slider, String) have a comprehensive story (`StoryControls.story.luau`) but no individual unit specs
- `Storybook/` — StoryError, StorybookError, StorybookTreeView, NoStorySelected, StoryMeta stories exist but untested
- `Telemetry/` — TelemetryOptOutDialog story exists but untested
- `UserSettings/` — SettingsView story exists but untested

**Story-only approach justification:** Stories serve dual duty: they let developers preview components interactively in Flipbook itself, and they render in the smoke test. For UI components, this is often sufficient (visual verification happens interactively). For business logic (stores, utilities), explicit specs are preferred.

---

## What Counts as Evidence in a PR

A fix claim requires one of the following:

### 1. Failing → Passing Spec (Strongest Evidence)

A spec that fails before the fix and passes after, demonstrating the specific behavior was broken and is now corrected.

**Example:** "Added test for ControlGroup flattening in `createStoryControlsStore.spec.luau`. Before fix: test fails (schema not flattened). After fix: test passes."

**How to write:**
```luau
test("flattens ControlGroup into flat control schema", function()
  local schema = {
    group = Storyteller.createControlGroup({
      a = Storyteller.createStringControl("hello"),
      b = Storyteller.createNumberControl(5),
    }),
  }
  local store = createStoryControlsStore(schema)

  -- After fix, getControls() should flatten group structure
  expect(store.getControls()).toEqual({
    a = "hello",
    b = 5,
  })
end)
```

### 2. Documented Manual Verification Recipe (Fallback when tests cannot run)

A step-by-step procedure proving the behavior works. Requires screenshots or concrete observations, not "works on my machine."

**Example:** "Fix for InstancePicker not displaying selected instances. Verification: (1) Open Flipbook. (2) Open StoryControls story. (3) Locate Object control. (4) Click 'Select Instance' button. (5) Click on a ModuleScript in Explorer. (6) Object control shows instance name and path. Screenshot: [attached]."

**Measurement guidance:** Use `flipbook-diagnostics-and-tooling` skill for logging, filtering, and sourcemap inspection rather than eyeballing.

### 3. Code Review + Type Check (Minimal)

The fix is simple (typo, const rename, obvious logic), all tests pass, and type-check passes. Example: "Renamed `storageKey` to `policyKey` throughout Telemetry store. No behavioral change, grep confirms all references updated, all tests pass."

---

## NOT Evidence

- "Works on my machine" (screenshot without steps, no measurement)
- "All tests pass" (does not mean the fix is correct, only that no existing tests broke)
- "I read the code and it looks right" (code review without execution)

---

## How to Write a Spec

### File Placement & Naming

Colocate `*.spec.luau` files next to the module they test. Example:

```
src/StoryControls/
  createStoryControlsStore.luau       ← module
  createStoryControlsStore.spec.luau  ← spec
```

### Minimal Example

```luau
local JestGlobals = require("@pkg/JestGlobals")
local Storyteller = require("@pkg/Storyteller")

local createStoryControlsStore = require("./createStoryControlsStore")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

describe("createStoryControlsStore", function()
  test("returns schema defaults", function()
    local schema = { name = Storyteller.createStringControl("Alice") }
    local store = createStoryControlsStore(schema)

    expect(store.getControlValue("name")()).toBe("Alice")
  end)

  test("overrides persist after setControl", function()
    local schema = { name = Storyteller.createStringControl("Alice") }
    local store = createStoryControlsStore(schema)

    store.setControl("name", "Bob")

    expect(store.getControlValue("name")()).toBe("Bob")
  end)
end)
```

### Jest Idioms Specific to Luau + jsdotlua

| Pattern | Luau Jest | Notes |
|---------|-----------|-------|
| **Import globals** | `local test = JestGlobals.test` | Do NOT use `require("jest")` or Node-style globals |
| **Describe** | `describe(name, fn)` | Groups related tests |
| **Test** | `test(name, fn)` or `it(name, fn)` | Defines a single test case |
| **Expect** | `expect(value).toBe(expected)` | Assertion; supports `.toEqual()`, `.toContain()`, etc. |
| **Before/After** | `beforeEach(fn)`, `afterEach(fn)` | Setup/teardown per test |
| **React Testing** | `ReactRoblox.act()`, `root:render()`, `root:unmount()` | Wrap renders in `act()` |
| **Instances** | Create with `Instance.new("ScreenGui")` | Tests run inside Roblox; use real Instance APIs |
| **Signals** | Use `Instance.new("BindableEvent")` for reactivity | Emit with `:Fire()` to trigger hook updates |
| **Skip** | `test.skip()` or `describe.skip()` | Temporarily disable without deleting |

### Real Example: Hook Testing

From `usePrevious.spec.luau`:

```luau
local container = Instance.new("ScreenGui")
local root = ReactRoblox.createRoot(container)

local toggleState = Instance.new("BindableEvent")

local function HookTester()
  local state, setState = React.useState(false)
  local prev = usePrevious(state)

  useEvent(toggleState.Event, function()
    setState(not state)
  end)

  return React.createElement("TextLabel", {
    Text = tostring(prev),
  })
end

afterEach(function()
  ReactRoblox.act(function()
    root:unmount()
  end)
end)

test("use the last value", function()
  local element = React.createElement(HookTester)

  ReactRoblox.act(function()
    root:render(element)
  end)

  local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel
  expect(result.Text).toBe("nil")

  ReactRoblox.act(function()
    toggleState:Fire()
  end)

  ReactRoblox.act(function()
    task.wait()
  end)

  expect(result.Text).toBe("false")
end)
```

Key patterns:
- Create an Instance (`ScreenGui`) as the render target
- Create a `BindableEvent` to signal state changes from outside
- Render component with `ReactRoblox.act()`
- Query the result with `:FindFirstChildWhichIsA()`
- Assert on Instance properties (Text, AbsoluteSize, etc.)

### Testing Stores (Charm-based)

From `createStoryControlsStore.spec.luau`:

```luau
test("returns the schema default before any override is set", function()
  local store = createStoryControlsStore(createSchema())

  expect(store.getControlValue("name")()).toBe("Alice")
end)

test("returns the same getter reference on repeated calls for the same key", function()
  local store = createStoryControlsStore(createSchema())

  local getter1 = store.getControlValue("name")
  local getter2 = store.getControlValue("name")

  expect(getter1).toBe(getter2)
end)
```

Key patterns:
- Stores return signal getters; call them with `()` to read current value
- Test signal identity stability (same getter object on repeated calls)
- Test that overrides do not bleed into other controls

---

## Running Tests

### Full Suite (All 16 specs, All 49 stories smoke-test)

```bash
lute run test
```

Requires `ROBLOX_API_KEY`. Output shows passed/failed counts. Exit code is non-zero if any test fails.

### Filtered Run (e.g., only control-related tests)

```bash
lute run test --filter "StoryControls"
```

`--filter` sets `_G.JEST_TEST_PATH_PATTERN` (via Darklua) to match spec paths. Example: `--filter "TreeView"` runs only `createTreeNodeStore.spec.luau`.

### With Explicit API Key

```bash
lute run test --apiKey "roblox_open_cloud_key_here"
```

Or set `.env`:
```
ROBLOX_API_KEY=roblox_open_cloud_key_here
ROBLOX_UNIT_TESTING_PLACE_ID=123506190725771
ROBLOX_UNIT_TESTING_UNIVERSE_ID=6599100156
```

### Failed Test Debugging

If a test fails, the output includes:
- Assertion error (expected vs actual)
- Stack trace with line numbers
- Which test suite failed

**Common causes:**
- Instance not found (`.FindFirstChildWhichIsA()` returns nil)
- Signal not subscribed (hook not updating)
- Type mismatch (string expected, got number)
- React render not wrapped in `act()`

Use `flipbook-debugging-playbook` for detailed triage.

---

## Honest Fallback: When Cloud Tests Cannot Run

If `ROBLOX_API_KEY` is unavailable (local setup, CI on fork, dev environment):

### Fallback Priority

1. **Run lint + analyze** (both work offline):
   ```bash
   lute run lint
   lute run analyze
   ```
   These catch ~80% of bugs (style, types, dead code). Accept it as sufficient for typos, renames, obvious fixes.

2. **Manual smoke-test** (documented recipe):
   Build the plugin and verify in Studio. Example: "Built dev plugin, opened Flipbook, opened StoryControls story, changed a string control, verified the component re-rendered only the changed control (not the entire panel)."

3. **Code review + type check** (careful but not airtight):
   For tiny changes (const renames, logic simplification), defer to reviewer judgment if tests are blocked.

### Document Fallback Status in PR

If tests could not run, add to PR body:
```markdown
**Testing note:** Cloud tests require ROBLOX_API_KEY (unavailable in this environment).
Fallback validation: ✅ lint, ✅ analyze, ✅ manual smoke-test (see #123 for steps).
```

---

## ContextProvider Error FIXME

**Known Gap:** `createFlipbookApp.luau` (grep `FIXME: ContextProviders having an error won't fail tests`)

If a ContextProvider (React context provider at the root of the app) throws an error, the error is caught by React's error boundary and the test sees an empty tree. The test passes even though the app is broken.

**Why it exists:** Error boundaries are how React handles errors in production; removing it would make errors uncontained and crash the whole app.

**Mitigation:** Add a dedicated smoketest that explicitly mounts the full app and checks for errors. This is not yet in the test suite; it's a known TODO.

**For now:** If you change ContextProviders or the app initialization, do a manual smoke-test: open Flipbook in Studio and verify the UI renders (not blank, no errors in Output).

---

## CI Integration

CI runs the three tiers on every PR:

1. **`analyze` job** (`.github/workflows/ci.yml`) — blocks merge if it fails
2. **`lint` job** — blocks merge if it fails
3. **`test` job** (`.github/workflows/strict.yml`) — cloud Jest tests; fork PRs require approval via `luau-execution-gated` environment

All three must pass for a PR to merge. If cloud tests are unavailable, CI will fail; you must run locally or request a review bypass (rare).

---

## Adding a Test

### 1. Write the Spec

```bash
# Create the .spec.luau file next to your module
touch workspace/flipbook-core/src/MyFeature/MyModule.spec.luau
```

### 2. Import JestGlobals and Dependencies

```luau
local JestGlobals = require("@pkg/JestGlobals")
local MyModule = require("./MyModule")

local test = JestGlobals.test
local expect = JestGlobals.expect
```

### 3. Write Test Cases

```luau
test("my feature does X", function()
  local result = MyModule.doSomething()
  expect(result).toBe("expected")
end)
```

### 4. Run Locally

```bash
lute run test --filter "MyModule"
```

### 5. Commit and Push

Jest auto-discovers `*.spec` files. No config changes needed.

---

## Stories as Validation Artifacts

Every component should have a `.story.luau`. Stories are:

1. **Interactive preview** — visible in Flipbook UI; developers preview while building
2. **Smoke test carrier** — `stories.spec.luau` renders each story and verifies mount/unmount

**Adding a story:**

```luau
-- src/MyFeature/MyComponent.story.luau
local React = require("@pkg/React")
local MyComponent = require("./MyComponent")

local story = {
  story = function(props)
    return React.createElement(MyComponent, {
      text = props.controls.text,
    })
  end,
  controls = {
    text = Storyteller.createStringControl("Hello"),
  },
}

return story
```

**Expectations:**
- Every interactive component has a story
- Stories with controls let developers test the component's interface
- Stories are colocated with the component

---

## Provenance and Maintenance

**Re-verification commands (run these if docs drift):**

- Test count: `find workspace/flipbook-core/src -name "*.spec.luau" | wc -l` (should be 16 or more)
- Story count: `find workspace -name "*.story.luau" | wc -l` (should be 49 or more)
- Jest config: `cat workspace/flipbook-core/src/jest.config.luau` (verify `testMatch` and `testPathIgnorePatterns`)
- Test runner: `cat workspace/test-runner/src/init.luau` (verify Jest is invoked with `testPathPattern`)
- Lint: `lute run lint` (verify it runs Selene, StyLua, Prettier)
- Analyze: `lute run analyze` (verify it runs luau-lsp in strict mode)
- Test: `lute run test --filter "usePrevious"` (verify tests build and run)

Last verified: 2026-07-01. Darklua 0.17.1, lute 1.0.0, Jest 3.10.0 (jsdotlua), Rocale via Luau Execution.
