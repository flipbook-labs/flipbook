---
name: flipbook-proof-and-analysis-toolkit
description: >
  First-principles analysis methods for Flipbook: six recipes to prove claims via mechanism, not inspection. Includes require-graph verification, module-reload isolation, rerender measurement, build determinism auditing, type-level proof via Luau analysis, and dependency-contract reading. Use when validating a build change, debugging state bugs, or claiming a fix works—before trusting the build, measure the mechanism.
type: process
---

# Flipbook Proof and Analysis Toolkit

When you claim "the build bakes X correctly" or "fix Y actually isolates the re-render" or "this state bug is module-reload, not Charm," prove it with a mechanism, not inspection. This skill teaches six recipes, each with a worked example from Flipbook's actual failure archaeology. A claim is proven when one mechanism explains all observations, including what *didn't* happen.

## When to Use This Skill

Use this skill to:
- Verify a build change actually reached the built artifact (don't assume Darklua processed it)
- Prove a React re-render claim with a counter instead of eyeballing flicker
- Isolate whether a stale-state symptom lives in ModuleLoader's registry, Storyteller's lifecycle, or Charm state
- Confirm a built artifact contains the injected global you think you set
- Use Luau's type analyzer as a theorem checker to rule out entire classes of bugs
- Read package sources (Storyteller, ModuleLoader, Charm) to verify what they actually do

Do NOT use this skill for:
- UI/visual verification (use `/verify` to run the app)
- Test execution (use `lute run test` for that)
- Lint/analyze discipline (that's in `flipbook-validation-and-qa`)
- Finding where code is (use `/explore` for code search)

Cross-reference instead: `flipbook-build-and-toolchain` for Darklua pipeline depth; `flipbook-diagnostics-and-tooling` for measurement infrastructure; `flipbook-failure-archaeology` for symptom→root-cause playbook.

---

## Recipe 1: Require-Graph and Transform Verification

**When to use:** After a Darklua transform, verify one module actually maps correctly through sourcemap → build output. Don't assume the build succeeded just because `lute run build` exited 0.

**The problem:** Darklua converts Luau-style string requires (`@pkg/Charm`, `@workspace/StoryView`, etc.) to Roblox `require()` statements using a sourcemap. If the sourcemap is stale, the transform wrong, or a path not indexed, the final build can have require-chains pointing to nil, broken paths, or baked-in absolute paths instead of instance-hierarchy references.

**The discipline:** Pick one module you claim has changed, trace it through three stages: (1) sourcemap input (raw entry), (2) Darklua transform (requires rewritten), (3) build output (final Roblox require). All three must agree on the mapping.

### Recipe: Require-Graph Verification

1. **Identify the module to trace:** pick a module you know changed (e.g., `workspace/flipbook-core/src/Http/requestAsync.luau` if you changed how the backend is called, or `workspace/flipbook-core/src/Telemetry/fireEventAsync.luau` which reads `_G.BASE_URL`).

2. **Read the sourcemap:** the sourcemaps live at the repo root — `sourcemap.json` (for luau-lsp) and `sourcemap-darklua.json` (the one Darklua's `convert_require` rule consumes, per `.darklua.json`).
   ```bash
   jq '.. | objects | select(.filePaths? and (.filePaths | join(",") | contains("requestAsync")))' sourcemap-darklua.json
   ```
   Look for: the instance name and its position in the tree — that hierarchy is what require paths are rewritten against.

3. **Identify the build's require statement:** In the build output for that module, find the `require()` call(s) and their argument. Darklua rewrites string requires into Roblox instance-path requires.
   ```bash
   # Dev plugin build output mirrors the source tree under build/<channel>/<target>/
   ls build/dev/roblox/
   grep -n "require(" build/dev/roblox/workspace/flipbook-core/src/Http/requestAsync.luau
   ```

4. **Cross-check with the sourcemap:** the rewritten `require(script.Parent....)` chain must match the instance hierarchy in `sourcemap-darklua.json`. If it doesn't, the sourcemap was stale at build time — rebuild with `--clean`.

5. **Inject a test require and verify:** Add a temporary global in the module to signal it loaded:
   ```luau
   -- In Backend.luau after requires
   _G.FLIPBOOK_BACKEND_MODULE_LOADED = true
   ```
   Build (`lute run build plugin --channel dev`), load the plugin in Studio, check the Output window:
   ```luau
   print(_G.FLIPBOOK_BACKEND_MODULE_LOADED)  -- Should print true
   ```

### Worked Example: PR #479 — BACKEND_URL Not Baked Into Build

**Symptom:** Nightly plugin logs "failed to communicate with backend: URL must be http"—BACKEND_URL is nil at runtime.

**Investigation steps (as done in PR #479):**

1. **Check the injection rule:** the backend URL is injected by Darklua as a global via an `inject_global_value` rule in `.darklua.json`. The variable is named `BASE_URL` today (it was `BACKEND_URL` at the time of PR #479):
   ```bash
   grep -A2 '"identifier": "BASE_URL"' .darklua.json
   # Expected: an inject_global_value rule with "env": "BASE_URL"
   ```

2. **Check CI build:** The nightly build CI doesn't copy `.env.template` → `.env` before calling `darklua`. Without `.env`, BACKEND_URL is unset.
   ```bash
   # In .github/workflows/release.yml before build step
   cat .env.template > .env  # Missing!
   ```

3. **Verify the injection path:** The build script reads the variable from the environment and passes it to Darklua. Note the naming: the variable was called `BACKEND_URL` at the time of PR #479; today it is `BASE_URL` (and Lute scripts moved from `scripts/` to `.lute/` in PR #521). Check the current chain:
   ```bash
   grep -n "BASE_URL" .lute/build.luau .darklua.json .env.template
   ```
   If `process.env.BASE_URL` is unset (missing `.env`), the injected `_G.BASE_URL` is nil in the artifact.

4. **The fix that landed — an explicit guard in the build script.** This is exactly what main has today (verified 2026-07-01, in `.lute/build.luau`, grep `if not process.env.BASE_URL`):
   ```luau
   if not process.env.BASE_URL then
       -- build errors out instead of silently baking nil
   ```

5. **Proof:** With the guard, a missing `.env` fails the build fast with a clear message instead of shipping an artifact that nil-dereferences at runtime.

**What makes this a proof:** The mechanism (Darklua global injection + environment variable read) is guarded by an explicit check. The failure is no longer silent. You've traced the value from env → `.darklua.json` inject rule → build artifact, verified each link, and confirmed a gate exists so the chain can't break silently.

---

## Recipe 2: Minimal Reproduction for Module-Reload/State Bugs

**When to use:** Isolate whether a stale-state symptom lives in ModuleLoader's require-cache, Storyteller's story-lifecycle state, or Charm's immutability guarantees. Module-reload bugs are context-dependent; a working test in CI doesn't prove a working Flipbook in Studio.

**The problem:** Flipbook's hot-reload workflow relies on ModuleLoader bypassing Roblox's native module cache, and Storyteller managing story-state lifecycles. If either goes wrong under certain re-renders or story switches, you get crashes like "Attempt to modify a readonly table" without a clear cause. The bug is live-state dependent—hard to reproduce without the full Studio workflow.

**The discipline:** Build a minimal story that triggers the suspected codepath, isolate each suspect (ModuleLoader cache, Storyteller state, Charm immutability), and remove candidates until one mechanism explains all symptoms.

### Recipe: Module-Reload/State Bug Isolation

1. **Symptom capture:** When the bug occurs, record: (a) which story, (b) which control change or re-render triggered it, (c) the exact error and stack trace.

2. **Create a minimal story file** that reproduces the symptom with the fewest moving parts:
   ```luau
   -- workspace/flipbook-core/example/MinimalReproduceFreeze.story.luau
   local Storyteller = require("@pkg/Storyteller")
   local Charm = require("@pkg/Charm")

   return Storyteller.createStory({
       name = "MinimalReproduceFreeze",
       storyType = Storyteller.StoryType.React,
       controls = {
           toggle = Storyteller.createBooleanControl(false),
       },
       render = function(props)
           local React = require("@pkg/React")
           local useState = React.useState
           
           local value, setValue = useState(props.controls.toggle)
           return React.createElement("TextLabel", {
               Text = tostring(value),
           })
       end,
   })
   ```

3. **Identify the suspect:** Does the bug happen on:
   - First load of the story? → Likely Storyteller or Charm initialization
   - After changing a control? → Likely store update or Charm mutation
   - After switching stories? → Likely ModuleLoader cache not cleared
   - After re-render? → Likely Charm immutability during state update

4. **Test ModuleLoader cache isolation:** Edit the story, save, and reload in Flipbook. If ModuleLoader's weak-keyed registry (the `weak()` helper in `Packages/_Index/flipbook-labs_module-loader@*/module-loader/dist/createModuleLoader.luau` — discover the installed version with `ls Packages/_Index | grep module-loader`) is working, the module should be GC'd and re-required. If not, stale closure state persists.
   ```luau
   -- In the story, add a module-level counter that should re-run on every reload
   _G.RELOAD_COUNT = (_G.RELOAD_COUNT or 0) + 1
   print("story module ran", _G.RELOAD_COUNT, "times")
   -- After editing and reloading, if the count did not increase, the cache didn't clear
   ```

5. **Test Storyteller lifecycle:** Switch to a different story, then back. If Storyteller's story state (createStorytellerStore) was not cleared, controls retain stale values.
   ```luau
   -- Story 1: set control to "A"
   -- Switch to Story 2
   -- Switch back to Story 1
   -- If control still shows "A" instead of default, state wasn't reset
   ```

6. **Test Charm immutability:** Check if the bug manifests only when Charm.flags.frozen is true. If so, the issue is a mutation inside Storyteller or a control handler.
   ```luau
   -- In src/PluginStarterScript.plugin.luau, try toggling the workaround
   Charm.flags.frozen = false  -- or true
   -- Reload and see if symptom changes
   ```

7. **Verify with instrumentation:** Add temporary logging to track state:
   ```luau
   -- In createStoryControlsStore.luau
   local function setControl(key, value)
       print(string.format("[setControl] %s = %s (was %s)", key, value, getControlValue(key)))
       -- ... actual update
   end
   ```
   Reload and check the Output window to see the order of state updates and whether mutations happen after Charm.freeze.

### Worked Example: storyteller#100 — Frozen-Table Crash

**Symptom:** "Attempt to modify a readonly table" crash when previewing stories in Flipbook after Storyteller's internal state mutations.

**Root cause investigation (as done in PR #509 + storyteller#100):**

1. **Storyteller switched from Signals to Charm (PR #509):** Charm provides immutable state with `Charm.flags.frozen = true` to prevent accidental mutations. Tests pass.

2. **Flipbook crashes after a story preview:** Error stack shows mutation inside Storyteller's state handler, but tests don't trigger it. **Inference: the mutation is context-dependent**—only happens when Flipbook's lifecycle (plugin load, story switch) interacts with Storyteller's state mutations.

3. **Minimal test:** Create a story with controls, change controls rapidly, switch stories. Crash occurs.

4. **Workaround implemented (PR #509 + PluginStarterScript):**
   ```luau
   Charm.flags.frozen = false  -- Disable Charm's immutability check
   ```
   Everything works. But the comment says "evil state bug will lurk in the shadows."

5. **Why it's proven but unresolved:** The mechanism is now known (Storyteller mutates state when Charm prevents it). The workaround proves the mechanism (disable immutability = no crash). But the root cause (why does Storyteller mutate?) is still in Storyteller code, not Flipbook's responsibility. Flipbook cannot ship without the workaround, and removing it would re-trigger the crash.

**What makes this a proof:** The mechanism (Charm.frozen flag toggling) directly controls the symptom (crash/no-crash). Changing one boolean eliminates the error. That isolates the cause to Charm immutability enforcement, not ModuleLoader or Storyteller's story-loading logic. The trade-off is documented: short-term workaround, long-term Storyteller refactor needed.

---

## Recipe 3: Rerender Accounting — Measurement Instead of Eyeballing

**When to use:** Claim a UI fix "stops controls from re-rendering on every change" and prove it with a counter, not a visual inspection.

**The problem:** Flickering or excessive re-renders are perceptually real but hard to prove. "It looks smoother now" is not evidence. React's scheduler may batch updates invisibly; console warnings are context-dependent. You need instrumentation.

**The discipline:** Add a render counter to each affected component, measure before and after the fix, show the diff. The proof is a number.

### Recipe: Rerender Counter Instrumentation

1. **Identify the component:** Pick the component you claim re-renders too much (e.g., `StoryControlRow` in control changes).

2. **Add a render counter at component entry:**
   ```luau
   -- In StoryControlRow.luau, at the top of the render function
   local renderCount = (_G.STORY_CONTROL_ROW_RENDERS or 0) + 1
   _G.STORY_CONTROL_ROW_RENDERS = renderCount
   if renderCount % 10 == 0 then
       print(string.format("[StoryControlRow] render count: %d", renderCount))
   end
   ```

3. **Build and run:** Load Flipbook, interact with controls, and watch the Output window.
   - **Before fix:** Changing one control triggers many re-renders of other control rows.
   - **After fix:** Only the changed control row increments its counter.

4. **Collect before/after numbers:** Run a specific sequence (e.g., toggle checkbox 5 times) and record the total render count for one component.
   ```luau
   print("Total renders before fix:", _G.STORY_CONTROL_ROW_RENDERS)
   ```

5. **Verify the mechanism:** The proof must show *why* the count dropped. Is it because:
   - The component no longer subscribes to a global store? (subscribe only to its own signal)
   - The parent no longer re-renders children? (React.memo or context isolation)
   - State updates are batched instead of cascading? (Charm computed signal stability)

### Worked Example: PR #576 — All Control Elements Rerendering

**Symptom (before fix):** Changing one control's value causes the entire `StoryControls` panel to re-render. Visual artifacts and React Scheduler warnings: "Maximum update depth exceeded."

**Analysis (as done in PR #576):**

1. **Pre-fix architecture:** All controls subscribe to a single `StoryControlsStore` that returned the entire control map on every change. Any setControl() update triggered all consumers.
   ```luau
   -- Bad: global subscription
   local allControls = storyControls.getControls()  -- Returns entire dict
   -- Any update to any control caused this component to re-render
   ```

2. **Counter placement:**
   ```luau
   -- In StoryControlRow before fix
   local renderCount = (_G.CONTROL_ROW_RENDERS or 0) + 1
   _G.CONTROL_ROW_RENDERS = renderCount
   ```
   Interact: toggle one boolean control 3 times.
   - **Result:** Total render count ≈ 33 (11 control rows × 3 updates each, all re-render on every change)

3. **Fix implementation (PR #576):**
   - Created per-control Charm signals in `createStoryControlsStore`:
     ```luau
     local function getControlValue(key)
         return Charm.computed(function()
             -- Only recompute when this specific control changes
             local overrides = overridesSignal:get()
             return overrides[key] or schema[key].default
         end)
     end
     ```
   - Each `StoryControlRow` subscribes to only its own signal via `useSignalState(controlValue)` (Charm subscriber pattern).
   - Result: only the changed row's component updates.

4. **Counter verification (after fix):**
   - Same sequence: toggle one boolean control 3 times.
   - **Result:** Total render count ≈ 3 (only the changed control's row re-renders; 10 other rows stay at 0)

5. **Measurement proof:**
   - Before: 33 renders total
   - After: 3 renders total
   - **Reduction: 90%**
   - Evidence: Per-control Charm computed signals + React context isolation isolate updates to changed component only.

**What makes this a proof:** The counter quantifies "re-render flicker" into a measurable reduction (90%). The mechanism is explicit: per-control signal subscriptions. Any regression would show up immediately in the counter. This is better evidence than "it looks smoother."

---

## Recipe 4: Build Determinism and Injected-Global Auditing

**When to use:** Verify the built artifact contains the injected global you think you set (BUILD_HASH, BUILD_CHANNEL, BUILD_VERSION, BASE_URL, LOG_LEVEL, etc.). Don't assume Darklua injects globals correctly.

**The problem:** Darklua replaces reads of `_G.BUILD_HASH`, `_G.BASE_URL`, etc. with literal values taken from environment variables at build time (`inject_global_value` rules in `.darklua.json`), then constant-folds and dead-code-eliminates around them. If an env var is unset (missing `.env`), the injected value is nil and the wrong branch may be eliminated. The build succeeds; the artifact is silently wrong.

**The discipline:** After building, verify the built artifact actually contains the injected values. Because injection SUBSTITUTES the `_G.X` read with a literal, you cannot grep the built output for `_G.BUILD_HASH` — it's gone. You grep for the literal value or its downstream effect.

### Recipe: Injected-Global Verification (verified 2026-07-01)

1. **Check `.darklua.json` configuration:**
   ```bash
   jq '.process[] | select(.rule? == "inject_global_value")' .darklua.json
   ```
   Eight rules as of 2026-07-01: BUILD_VERSION, BUILD_CHANNEL, BUILD_HASH, BUILD_TARGET, BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING, JEST_TEST_PATH_PATTERN — each fed from the same-named env var.

2. **Know where each value comes from before build:** BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING come from `.env` (copied from `.env.template`); BUILD_VERSION/BUILD_CHANNEL/BUILD_HASH/BUILD_TARGET are computed by `.lute/build.luau` (e.g. `BUILD_HASH = getCommitHash()`); JEST_TEST_PATH_PATTERN is set by `.lute/test.luau --filter`.

3. **Inspect the built artifact for the substituted literal:** dev plugin builds land in `build/dev/roblox/` mirroring the source tree.
   ```bash
   # The dev starter script bakes the hash into the plugin name:
   grep -n "Flipbook \[" build/dev/roblox/PluginStarterScript.plugin.luau
   # Expected: local PLUGIN_NAME = 'Flipbook [<short-hash>]'
   # A nil injection shows up as a malformed name or a folded-away branch.
   ```
   Note the hash is the commit at BUILD time — if it differs from `git rev-parse --short HEAD`, your build is stale; rebuild with `--clean`.

4. **Verify dead-code elimination did the right thing:** in a dev build, the source's `if _G.BUILD_CHANNEL == "development"` branch is folded to an unconditional `_G.__DEV__ = true` block; in a prod build that block is absent entirely.
   ```bash
   grep -n "__DEV__" build/dev/roblox/PluginStarterScript.plugin.luau   # present in dev
   grep -n "__DEV__" build/prod/roblox/PluginStarterScript.plugin.luau  # absent in prod
   ```

5. **Rebuild and re-verify:** After setting an env var or fixing `.env`, rebuild with `lute run build plugin --channel dev --clean` and verify the value changed.
   ```bash
   # Before: _G.BUILD_HASH = "old"
   # After: _G.BUILD_HASH = "new"
   ```

### Worked Example: PR #426 and PR #444 — BUILD_HASH Not Getting Set

**Symptom (PR #426):** After Lute migration, `BUILD_HASH` global is nil at runtime. Telemetry events have no hash.

**First investigation (PR #426, commit 1863e994):**

1. **Check Darklua config:** `.darklua.json` expects BUILD_HASH in env.
2. **Check build script:** the build script (then `scripts/build.luau`; moved to `.lute/build.luau` in PR #521) computes BUILD_HASH by shelling out to git — today via `getCommitHash()` feeding the Darklua env (in `.lute/build.luau`, grep `BUILD_HASH = getCommitHash()`). Illustrative shape of the failing pattern:
   ```luau
   -- illustrative, not a verbatim quote of the historical script
   local result = process.run("git", { "rev-parse", "--short", "HEAD" })
   -- if stdout is not captured, result.stdout is empty and BUILD_HASH is baked as nil
   ```
3. **Problem:** Lute's `process.run()` doesn't capture stdout by default. The result.stdout is empty or nil.
4. **Fix:** Check Lute's default behavior; explicitly set stdio to capture output.
5. **Proof:** After fix, rebuild (`--clean` to invalidate cache), check Output window:
   ```luau
   print(_G.BUILD_HASH)  -- Now prints actual hash, e.g., "abc123"
   ```

**Second failure (PR #444, commit 704fbd5b):**

1. **Same symptom:** BUILD_HASH is nil again, just weeks after PR #426.
2. **Root cause:** Lute's stdio behavior changed between versions (process-spawning brittleness).
3. **Permanent fix (PR #444):**
   - Explicitly set stdio parameter: `.stdio = "default"`
   - Added an assertion in CI to catch future regressions:
     ```luau
     assert(os.getenv("BUILD_HASH"), "BUILD_HASH failed to set in build script")
     ```
4. **Proof:** After fix, the assertion passes on every CI run. If stdio behavior changes again, the assertion will fail visibly, not silently.

**What makes this a proof:** The mechanism (Lute's stdio behavior → os.setenv → Darklua injection) is now guarded by an explicit assertion. The fix went from "hope it works" to "verify it works every build." The second fix added a permanent guard: any future breakage will be caught at build time, not at runtime when telemetry is nil.

---

## Recipe 5: Type-Level Proof with `lute run analyze` Strict Mode

**When to use:** Prove a claim like "this code cannot pass a nil value to setControl()" using Luau's strict type analyzer instead of runtime inspection.

**The problem:** Type-unsafe code can have bugs that are hard to catch with tests (nil dereference, wrong argument order, missing type conversions). Luau's strict mode type-checks the entire codebase and can rule out entire classes of bugs.

**The discipline:** Understand what strict mode checks (flow-based nil analysis, type mismatch detection, unused variables) and what it misses (dynamic `:: any` casts, type assertions). Use it to prove negative properties: "X *cannot* happen here because the type checker forbids it."

### Recipe: Type-Level Proof via Analyzer

1. **Run analysis with strict settings:**
   ```bash
   lute run analyze
   ```
   This builds type definitions and runs `luau-lsp analyze` in strict mode (as configured in `.luaurc`). Check for errors related to your claim.

2. **Understand what strict mode checks:**
   - **Nil flow analysis:** `if x then use(x)` proves x is not nil inside the if-block. Outside the if-block, x could be nil.
   - **Type narrowing:** Asserts and comparisons narrow types (e.g., `if type(x) == "string" then` narrows x to string).
   - **Function contracts:** Type annotations on parameters and return values are enforced.
   - **Unused code:** Dead assignments and unused variables are flagged.

3. **Look for known blind spots:** Luau's type analyzer has gaps:
   - **`:: any` casts bypass the type system:** Any claim that depends on strict typing is void if the code uses `:: any`.
   - **Metatable tricks:** Custom `__index` or mutation via `setmetatable` can't be fully type-checked.
   - **Runtime globals:** `_G.X` is always typed as `any`.
   - **Package reflection:** Mutations to shared state across module boundaries.

4. **Search for `:: any` in critical paths:**
   ```bash
   grep -r ":: any" workspace/flipbook-core/src/
   ```
   If your claim's critical path includes a `:: any` cast, the type proof is incomplete. Document this.

5. **Add type annotations to strengthen the proof:** If a function currently accepts broad types, add strict type annotations:
   ```luau
   -- Before: implicit types
   local function setControl(key, value)
       table.insert(controls, { key = key, value = value })
   end

   -- After: explicit types, strict mode can now prove properties
   local function setControl(key: string, value: any): nil
       assert(type(key) == "string", "key must be a string")
       table.insert(controls, { key = key, value = value })
   end
   ```

### Worked Example: TreeView/createTreeNodeStore.luau — `:: any` Cast

**Location:** `workspace/flipbook-core/src/TreeView/createTreeNodeStore.luau`, in the `setSortOrder` function

**Context:** This file manages the tree view's node state using Charm signals. The code notes a `:: any` cast.

**What the cast does:** In the `setSortOrder` function, a signal is cast to `any` (grep `return sort :: any`):

**Why it's there:** Luau's strict mode can't fully infer the complex return type of Charm's computed signals, especially when signals subscribe to other signals and produce nested structures. The cast lets the code compile.

**What strict mode can *not* prove in this file:** 
- That nodeStore's properties are correctly typed (they're hidden behind `any`)
- That mutations through nodeStore follow the expected schema
- That signal subscriptions have correct closure lifetimes

**What strict mode *can* still prove elsewhere:**
- Function parameter types (non-any parts)
- Nil dereference in other modules that consume nodeStore

**How to strengthen the proof:**
1. Export a type alias from Charm that describes the computed signal's return type
2. Replace `:: any` with the concrete type
3. Re-run `lute run analyze`; strict mode now has more information

**Caveat:** If you're working in strict mode, assume that `:: any` casts are intentional workarounds. The maintainer has explicitly allowed them because the alternative (rewriting Charm's types or refactoring the module) is more costly.

**What makes this a proof:** By identifying the `:: any` cast, you've documented the exact boundary where the type checker's guarantees end. That's a valid proof of *what strict mode cannot verify*—not just silence, but an explicit statement of the limitation.

---

## Recipe 6: Dependency-Contract Verification — Read the Package Source

**When to use:** You're claiming "ModuleLoader clears its registry on story change" or "Storyteller doesn't mutate control schema" and need to verify the package actually does what you think. Don't assume; read the source.

**The problem:** Dependencies like ModuleLoader, Storyteller, and Charm are in `Packages/_Index/` (via Wally). Their behavior is not obvious from usage alone. A bug could be a misunderstanding of what they actually do, not a bug in Flipbook code.

**The discipline:** Read the dependency source file by file. Trace the codepath that your claim depends on. Verify assumptions against the actual implementation.

### Recipe: Dependency-Contract Reading

1. **Locate the package source** (installed `_Index` versions drift across installs — discover them, never hardcode):
   ```bash
   # Example: ModuleLoader
   ML_DIR=$(ls -d Packages/_Index/flipbook-labs_module-loader@*/module-loader)
   ls "$ML_DIR"/dist/
   ```

2. **Identify the relevant entry point:** This is usually the public API or main module:
   ```bash
   # ModuleLoader's main export
   head -50 "$ML_DIR"/dist/createModuleLoader.luau
   ```
   Look for: exported functions, class/object shape, documented contract.

3. **Trace the codepath for your claim:** If you claim "ModuleLoader lets stale modules be garbage-collected," find where that happens:
   ```bash
   # Search for weak-table setup (indicates GC-able cache)
   grep -n "__mode" "$ML_DIR"/dist/createModuleLoader.luau
   ```

4. **Read the mechanism** (verified 2026-07-01 against installed module-loader@0.10.2): a `weak()` helper wraps registry tables in weak keys:
   ```luau
   local function weak<K, V>(tab: { [K]: V }): { [K]: V }
       return setmetatable(tab, { __mode = "k" }) :: any
   end
   -- __mode = "k" means keys are weak references (GC'd when no other refs exist),
   -- so an unreferenced module entry is automatically removed from the registry
   ```

5. **Verify the GC behavior:** When does the weak reference get released?
   ```bash
   grep -n "weak(" "$ML_DIR"/dist/createModuleLoader.luau
   # Look for: which registries are weak, where entries are assigned and released
   ```
   Trace the lifecycle: module is loaded → tracked in weak-keyed registries → when the story changes, the old module loses its references → GC removes it → the next require re-loads source.

6. **Check for mutations or side effects:** Does the package mutate global state that could violate Flipbook's assumptions?
   ```bash
   grep -n "_G" "$ML_DIR"/dist/createModuleLoader.luau
   # ModuleLoader builds a globals table with __index = _G for loaded modules
   ```

### Worked Example: Object-Control Migration Drop

**Claim:** UILabs.Advanced.Object controls can be migrated to Storyteller ObjectControl.

**Investigation (as discovered in story-controls briefing):**

1. **Locate Storyteller migration code** (the installed `_Index` version drifts across installs — discover it, don't hardcode):
   ```bash
   ST_DIR=$(ls -d Packages/_Index/flipbook-labs_storyteller@*/storyteller)
   cat "$ST_DIR"/dist/controls/migrations/ui-labs-*/migrateUILabsControl.luau
   ```

2. **Find the Object type case:**
   ```bash
   grep -n "Object" "$ST_DIR"/dist/controls/migrations/ui-labs-*/migrateUILabsControl.luau
   # Result: Line ~67 (verified 2026-07-01 against installed storyteller@1.11.0)
   ```

3. **Read the migration logic:**
   ```luau
   -- Line 68 (verified)
   elseif control.Type == "Object" then
       return nil  -- ← MIGRATION FAILS SILENTLY
   ```

4. **Identify the contract violation:** The migration function promises to convert UILabs controls to Storyteller controls. But for Object type, it returns nil (not an error, not a converted control). The schema author loses Object controls without feedback.

5. **Check if Storyteller has ObjectControl support:** Look at ControlTypes.luau:
   ```bash
   grep -n "ObjectControl" "$ST_DIR"/dist/controls/ControlTypes.luau
   ```
   Result: `ObjectControl` type is defined. Storyteller *can* handle Object controls; the migration just doesn't convert them.

6. **Conclusion:** The contract is broken: Storyteller supports ObjectControl, but the UILabs migration silently drops Object controls. The fix is in Storyteller, not Flipbook.

**What makes this a proof:** By reading the dependency source, you've proven the contract violation. You didn't guess or test-and-hope; you read the line that breaks it (grep `return nil` in the dependency's type-conversion function). That's evidence strong enough to file an upstream issue or patch the dependency.

---

## Measurement Tools and Scripts

### Render Counter Template

Store this in `scripts/rerender-counter.luau` for quick setup:
```luau
-- Rerender counter instrumentation
-- Add to any component's render function entry:
--
-- local componentName = "ComponentName"
-- local renderCount = (_G[componentName .. "_RENDERS"] or 0) + 1
-- _G[componentName .. "_RENDERS"] = renderCount
-- if renderCount % 10 == 0 then
--     print(string.format("[%s] render count: %d", componentName, renderCount))
-- end

local function instrumentComponent(componentName, renderFn)
    return function(props)
        local renderCount = (_G[componentName .. "_RENDERS"] or 0) + 1
        _G[componentName .. "_RENDERS"] = renderCount
        return renderFn(props)
    end
end

return {
    instrumentComponent = instrumentComponent,
}
```

### Build Verification Checklist

Before claiming a build is correct, verify:

- [ ] `.env` file exists and contains all required vars (copy from `.env.template` if not)
- [ ] `lute run build --clean` succeeds (not just incremental)
- [ ] `grep -r "nil" build/<channel>/<target>/` for injected globals; none should be nil
- [ ] Sourcemap (`build/sourcemap.json`) has entries for all modified modules
- [ ] Run `lute run analyze` strict mode; no errors in critical paths (note `:: any` casts)
- [ ] Plugin loads in Studio and prints `_G.BUILD_HASH`, `_G.BUILD_CHANNEL` to Output; values non-nil
- [ ] Test story loads; controls render and respond to changes

---

## Provenance and Maintenance

Recipes and worked examples verified against Flipbook's git history (as of 2026-07-01):
- PR #479 (backend URL injection; variable now named BASE_URL) — grep `BASE_URL` in `.darklua.json`, `.lute/build.luau`, `.env.template`
- PR #426 & PR #444 (BUILD_HASH) — grep `BUILD_HASH` in `.lute/build.luau` (fed by `getCommitHash()`), check `process.run` stdio behavior in Lute docs
- PR #576 (rerender isolation) — read `createStoryControlsStore.luau`, `StoryControlRow.luau`, verify per-control Charm signals
- storyteller#100 (Charm.flags.frozen) — read `src/PluginStarterScript.plugin.luau` (comment block above `Charm.flags.frozen = false`), verify workaround in place
- ModuleLoader weak-keyed registry — read `Packages/_Index/flipbook-labs_module-loader@*/module-loader/dist/createModuleLoader.luau` (the `weak()` helper; installed version drifts, discover with `ls Packages/_Index | grep module-loader`)
- UILabs Object migration — read `Packages/_Index/flipbook-labs_storyteller@*/storyteller/dist/controls/migrations/ui-labs-*/migrateUILabsControl.luau` (the `control.Type == "Object"` branch returning nil; grep `"Object"` in installed 1.11.0 as of 2026-07-01)

To re-verify, run: `git log --oneline | grep -E "479|426|444|576|509"` and inspect each PR's commits. Then spot-check one recipe by building and running a minimal reproduction. If recipes or worked examples drift from the repo, update them here and re-date.
