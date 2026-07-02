---
name: flipbook-debugging-playbook
description: "Symptom→solution runbook for Flipbook runtime issues: stale plugin behavior, stories not hot-reloading, controls re-rendering excessively, crashes on state mutations, test failures, missing logs, plugin freezing or opening uninvited. Use when you encounter a runtime symptom and need to isolate root cause quickly via discriminating experiments."
type: process
---

# Flipbook Debugging Playbook

## When to use

Use this skill when you encounter a failure in Flipbook plugin development (stale behavior after edits, build cache issues, story reload problems, control render regressions, test cloud/local divergence, missing injected globals, Windows path errors, plugin auto-launch, or logging absent). Start with the symptom table, run the first check, then the discriminating experiment to isolate the root cause.

Do not use for: build system deep-dives (see `flipbook-build-and-toolchain`), releases/operations (see `flipbook-release-and-operations`), config/flag management (see `flipbook-config-and-flags`), test authoring (see `flipbook-validation-and-qa`), or state machine architecture (see `flipbook-architecture-contract`).

---

## Symptom Table: Real Failure Modes

### 1. Stale or Wrong Plugin Behavior After Edits

**Story:** When you change plugin code, the running instance in Studio still shows the old behavior. PR #596 ("Fix the dev build failing to deploy") revealed that dev builds sometimes don't redeploy after source changes.

**Symptom checklist:**
- Changed `workspace/flipbook-core/src/**/*.luau`, rebuilt, but Studio widget shows old behavior.
- No rebuild errors; Rojo shows green; but preview/controls/telemetry act stale.

**First check:**
```bash
lute run build plugin --channel dev --clean
```
This full rebuild wipes the build cache at `build/build-cache.json` and recompiles everything from scratch. If this fixes it, the issue is stale cache or partial rebuild.

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Build cache is corrupt | Cat `build/build-cache.json`, check if all workspace members list recent mtimes | Cache has old timestamps or missing members | Move to fix |
| Watch is not running | In a second terminal, run `lute run build plugin --channel dev --watch` while editing `workspace/flipbook-core/src/StoryView.luau` (add a comment). Do you see "Compiling..." output? | No output, file saved but build doesn't trigger | Check watch roots/exclusions in `.lute/build.luau` (grep `excludedFilePatterns`) |
| Editing build/ by mistake | Check git status; is anything in `build/` or `dist/` modified? | Staged/unstaged changes in `build/` | Undo edits: `git checkout build/ dist/` |
| Plugin reload skipped | Check if `--skip-reload` flag is in your command. See `.lute/build.luau` (grep `args:has("skip-reload")`) | `--skip-reload` is in your alias/script | Remove the flag |
| Dev channel not set | Run again with explicit `--channel dev`; check build output for "BUILD_CHANNEL = development" | Build shows "production" channel | `.env` is missing or BASE_URL env var unset; see config-and-flags skill |

**Fix:** Re-run `lute run build plugin --channel dev --clean`. If watch was broken, restart it. If you edited `build/` directly, undo via `git checkout build/ dist/` and rebuild.

**Escalation:** If `--clean` doesn't fix it after a rebuild, the source code itself may be wrong (not a build issue). Check the change you made compiles without Luau strict errors: run `lute run analyze` and read the output.

---

### 2. Darklua Require Conversion Failures (Sourcemap Drift)

**Story:** PR #535 ("Fix broken nightly build") and PR #479 ("Fix BACKEND_URL not getting baked into the build") revealed that Darklua's sourcemap dependency is fragile. Sourcemap path format changes (absolute vs. relative) and stale entries cause require-resolution to fail. The build outputs cryptic Darklua errors about "failed to resolve string require."

**Symptom checklist:**
- Build fails with error like: `[ERROR] Failed to resolve string require to path: @workspace/flipbook-core/src/FlipbookApp`
- Or: Darklua silently produces malformed requires (e.g., `require(nil)` in output).
- Stale sourcemap (from previous branch/checkout) doesn't match current source tree.

**First check:**
```bash
# Regenerate sourcemap
rojo sourcemap project.sourcemap.json -o build/sourcemap-darklua.json

# Check sourcemap sanity: does it list recent workspace members?
cat build/sourcemap-darklua.json | grep "FlipbookApp" | head -3
```

If sourcemap is empty or missing entries, Rojo didn't see the source tree.

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Sourcemap out of sync | Delete `build/sourcemap-darklua.json`, then `lute run build plugin --channel dev --clean` | Build succeeds; sourcemap regenerates | Sourcemap was stale; no fix needed (rebuild regenerates) |
| Source tree changed (branch switch) | Verify `workspace/flipbook-core/src/` exists and has `.luau` files: `ls workspace/flipbook-core/src/*.luau | wc -l` (should be >5) | <5 files or `No such file` | You're on a branch without flipbook-core; switch back to main or merge with main |
| Darklua using wrong sourcemap path | Check `.darklua.json` (grep `"rojo_sourcemap"`): does it say `"./sourcemap-darklua.json"`? | Path is different (e.g., `sourcemap.json`) | Verify you're on current main; the build system may have changed on your branch |
| SOURCE_PATH is absolute instead of relative | Look at `.lute/lib/build-system/compileAsync.luau` (grep `path.relative`): it converts `SOURCE_PATH` to relative. Run the build with full verbosity: `lute run build plugin --channel dev 2>&1 | grep "darklua"` and check the path argument. | Absolute path starting with `/Users/` passed to darklua | This is a path normalization bug in the build script; escalate (unlikely on main) |

**Fix:** Re-run `lute run build plugin --channel dev --clean`. The Rojo sourcemap will regenerate. If you just switched branches, run `lute run install` to ensure workspace members are on disk, then rebuild.

**Escalation:** If sourcemap regenerates correctly but Darklua still fails, the issue is not sourcemap drift; check if a `.luau` file has a malformed `@workspace/` require (typo in path). See `flipbook-build-and-toolchain` for Darklua require rules.

---

### 3. "Attempt to Modify a Readonly Table" Crashes

**Story:** PR #509 migrated from Signals to Charm state management. Storyteller internally mutates Charm-wrapped state, violating Charm's immutability guarantee. Workaround added in `src/PluginStarterScript.plugin.luau`: `Charm.flags.frozen = false` (comment: "evil state bug will lurk in the shadows"). Upstream issue: `flipbook-labs/storyteller#100` (unresolved).

**Symptom checklist:**
- Clicking a story control in Flipbook causes immediate crash: "attempt to modify a readonly table" in error output.
- Crash happens only when previewing stories (not in the plugin UI itself).
- No fix without restarting Studio.

**First check:**
```bash
# Verify the workaround is in place
grep -A2 "Charm.flags.frozen = false" src/PluginStarterScript.plugin.luau
```

If you see the line, the workaround is active. If not, this is a code regression.

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Workaround disabled | Check `src/PluginStarterScript.plugin.luau` (grep `Charm.flags.frozen`); is it present and set to `false`? | Line is gone or commented out | Add it back immediately; this is a load-bearing line |
| Storyteller version mismatch | Check `wally.toml` line for Storyteller: `storyteller = "flipbook-labs/storyteller@..." `. Does the version match what's in `Packages/_Index/`? | Versions differ | Run `lute run install` to sync versions |
| Story code mutating state directly | Create a minimal story that declares controls but does NOT interact with them. Does it crash? | Minimal story works fine | The crash is in your story code (you're mutating control state), not Charm. Debug your story logic. |
| Fresh Rojo compile needed | Run `lute run build plugin --channel dev --clean` | Crash persists | Move to next step |

**Fix:** The workaround `Charm.flags.frozen = false` is permanent. Do not remove it. If you removed it (to "fix" a different issue), add it back. If the crash is in YOUR story code, audit for direct table mutations on control values.

**Escalation:** If crashes persist despite the workaround present, the issue is deeper in Storyteller's state mutation logic. File an issue on `flipbook-labs/storyteller` with a minimal story that triggers the crash and the full Luau stack trace.

---

### 4. Stories Not Reloading or Reloading with Stale State

**Story:** ModuleLoader (`Packages/_Index/flipbook-labs_module-loader@*/module-loader/dist/createModuleLoader.luau` — the installed version drifts, locate it with `ls Packages/_Index | grep module-loader`) bypasses Roblox's native require cache using weak-keyed registries (a `weak()` helper wraps its tables in `setmetatable(tab, { __mode = "k" })`). Hot-reload works because modules are GC'd when source changes. But stale state persists if: the module isn't actually reloading, or the story function isn't being re-invoked.

**Symptom checklist:**
- Changed a story file (e.g., `StoryControls.story.luau`), saved, but Flipbook preview shows old rendered output.
- Changed story control schema; preview still shows old schema.
- `lute run build plugin --channel dev --watch` is running, but story didn't re-render.

**First check:**
```bash
# Verify watch is running and detected your change
# 1. Tail the build output (in the terminal running lute --watch)
# 2. Edit workspace/flipbook-core/src/StoryView.luau (add a comment)
# 3. Do you see "Compiling workspace/flipbook-core" output?
# 4. Did Studio's output window show a plugin reload message?

# Check the story is being loaded at all
grep -n "moduleName\|loadStoryModule" workspace/flipbook-core/src/Storybook/*.luau | head -5
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Watch not running | Is `lute run build plugin --channel dev --watch` still running in its terminal? | Terminal shows "waiting for changes..." or is idle | Rebuild with fresh watch: stop old one, run new one |
| Story file not under watch roots | Check `.lute/build.luau` (grep `excludedFilePatterns`). Does your story file match an exclusion? | Your `.story.luau` file is in `code-samples/`, `example/`, or `template/` (prod-pruned dirs) | These dirs are in watch roots but might not recompile in prod channel. Use `--channel dev` |
| Module not actually reloading | Open Roblox output window (Help > Logs). Do you see "ModuleLoader: reloading <moduleName>"? | No reload message | ModuleLoader isn't detecting the change; check if the file is actually being written to disk |
| Story component still holding old value in closure | The story render function memoizes a value; reloading the source doesn't update the closure. Example: `local state = Instance.new("Folder")` outside the story function. | Story function is not top-level, or uses external references | Refactor story to re-evaluate on each render (move state inside story function) |
| Storyteller not re-calling story function | Verify the story is wrapped in Storyteller: does it return `{ render = function(props) ... end }`? | Story is raw render function, not Storyteller-wrapped | Wrap with Storyteller: `return { render = function(props) ... end }` |

**Fix:** Re-run `lute run build plugin --channel dev --watch`. If watch is stalled, kill it and restart. If the story is still stale after watch re-triggers, the story code itself has a stale reference (closure bug). Move dynamic values inside the render function.

**Escalation:** If the story IS reloading (you see the ModuleLoader message) but the preview doesn't update, the issue is React/Fusion not re-rendering. Check if the story is wrapped in `React.memo()` without dependencies: remove the memo or add dependencies array.

---

### 5. Controls Rerendering Problems (Post-#576 World)

**Story:** PR #576 ("Fix all control elements rerendering when one is changed") introduced `createStoryControlsStore()` and `StoryControlsContext` to isolate control state into per-control Charm signals. Before #576, changing one control triggered a full panel re-render, causing flicker and performance issues. After #576, only the changed control updates.

**Symptom checklist:**
- Changing one control (e.g., a slider) causes ALL controls in the panel to flicker or re-render.
- React profiler shows "StoryControls" component re-rendering even though only one child changed.
- Console shows "setState on unmounted component" or spurious warnings.

**First check:**
```bash
# Verify you're on or after PR #576 (commit 371d7752, May 30 2026)
git log --oneline --all | grep -i "fix.*control.*re" | head -3

# Verify createStoryControlsStore exists
ls -la workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau
```

If the file doesn't exist, you're on an old branch or before the fix was merged.

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| On old branch before #576 | Run `git log --oneline -1` and check the commit date. Is it before May 30 2026? | Yes, old commit | Merge main: `git merge main` (or rebase if preferred). Resolve conflicts in `StoryControls/`. |
| Custom control component missing context | In your custom control element (e.g., `MyControl.luau`), do you call `useStoryControlsStore()`? | No, you're directly consuming props | Refactor to use context: `local store = useStoryControlsStore(); local value = store.getControlValue(controlName)` |
| Store not subscribed per-control | Check `StoryControlRow.luau` (grep `useSignalState`). Does it call `useSignalState(storyControls.getControlValue(props.controlName))`? | No, it's subscribing to the entire schema | Verify you're on main (or after #576); this is the fix. Re-merge if needed. |
| StoryControlsContext not providing store | Check `StoryView.luau`: does it wrap the story in `StoryControlsContext.Provider`? | No provider, or provider wrapping is wrong level | Add/fix the provider to wrap `<StoryControls />`; see the provider wrapping in `StoryControls.story.luau` for an example |

**Fix:** If on an old branch, merge main and resolve conflicts. If after #576, verify `StoryControlsContext.Provider` wraps your control panel, and each control subscribes via `useSignalState()`.

**Escalation:** If re-renders persist after verifying the store architecture, use React DevTools to profile which component is re-rendering and why. See `flipbook-diagnostics-and-tooling` for profiling recipes.

---

### 6. Tests Failing in Cloud vs. Locally-Unrunnable

**Story:** `lute run test` runs Jest in the cloud (Rocale/Luau Execution) against a test place in the ROBLOX_UNIT_TESTING universe. Local test runs (if any) use Rojo + Jest, but rely on `ROBLOX_API_KEY` to upload the place. PR #559–#563 (fork workflow) introduced environment gating; fork PRs require approval to run tests.

**Symptom checklist:**
- `lute run test` fails in CI with "401 Unauthorized" or "missing ROBLOX_API_KEY".
- Locally, `lute run test` runs fine; in cloud CI, tests hang or timeout.
- `--filter` pattern doesn't work or behaves differently.

**First check:**
```bash
# Verify ROBLOX_API_KEY is set
echo $ROBLOX_API_KEY

# Check test config: JEST_TEST_PATH_PATTERN
cat .env.template | grep -E "ROBLOX|JEST"

# Verify test place exists
echo "Universe: 6599100156, Place: 123506190725771"
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| ROBLOX_API_KEY missing | Run `echo $ROBLOX_API_KEY`. Is it empty? | Empty string or undefined | Set it: `export ROBLOX_API_KEY=<key>` (get key from Roblox account settings > Security > API tokens) |
| Fork PR without approval | Check GitHub Actions output: do you see "Skipped (requires approval)"? | Yes, skipped | Approval required for fork PRs. The repo maintainer must approve. Rerun after approval. |
| JEST_TEST_PATH_PATTERN filter not injected | Run with `--filter "StoryControls"`: does Darklua receive it? | Build output shows no env var injection for JEST_TEST_PATH_PATTERN | Verify `--filter` is passed correctly: `lute run test --filter "StoryControls"` |
| Test place invalid | Check `.lute/test.luau` (grep `ROBLOX_UNIT_TESTING_UNIVERSE_ID` and `ROBLOX_UNIT_TESTING_PLACE_ID`): what values are used? | Hardcoded values don't match .env.template | Sync: universe 6599100156, place 123506190725771 |
| Rocale timeout | Tests hanging for >30s in cloud | Rocale process killed by timeout (default ~3min) | Increase timeout or split tests into smaller batches with `--filter` |
| Local Rojo test place not created | Do you see `build/flipbook-test.rbxl` after `lute run test`? | File missing | Rojo build failed; check `.lute/lib/rojoBuild.luau`. Re-run with verbose: `lute run test 2>&1 | tail -50` |

**Fix:** Set `ROBLOX_API_KEY` locally. In CI, ensure the test runs in an environment with the key (not a fork PR without approval). Use `--filter` to reduce test count if cloud timeout.

**Escalation:** If tests pass locally but fail in cloud, the issue is environment difference (Rocale's Luau execution is stricter than Studio). Check console output for Luau type errors. If a single test hangs, isolate it with `--filter <testName>` and profile with Rocale's debug output.

---

### 7. BUILD_HASH / BUILD_VERSION / BASE_URL Missing at Runtime

**Story:** Darklua injects globals at build time from env vars. PR #426 and PR #444 both fixed "BUILD_HASH not getting set" — the issue recurred due to Lute stdio behavior variance across versions. PR #479 fixed BASE_URL missing (CI didn't copy `.env.template` → `.env`). These are "injected-global failures."

**Symptom checklist:**
- At runtime (in plugin output or Story props), `_G.BUILD_HASH`, `_G.BUILD_VERSION`, or `_G.BASE_URL` are nil.
- Plugin title shows "Flipbook []" (hash is nil) instead of "Flipbook [abc1234]" in dev channel.
- API calls to Backend fail with "URL must be http" (BASE_URL was nil).

**First check:**
```bash
# Verify env vars are set before build
cat .env | grep "BASE_URL\|BUILD"

# Check if .env exists (should be copied from .env.template)
ls -la .env

# Verify Darklua got the values: check build cache
cat build/build-cache.json | grep -A2 "env"
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| .env file missing | Is `.env` present? | No `.env` file | Copy it: `cp .env.template .env` |
| BASE_URL unset in .env | `grep "BASE_URL" .env` | `BASE_URL=` (empty) or line missing | Add/set it: `echo "BASE_URL=https://apis.flipbooklabs.com" >> .env` |
| BUILD_HASH extraction failed | Look at `.lute/build.luau` (grep `getCommitHash`): it runs `git rev-parse --short HEAD`. Does git work? | Git not installed or not in PATH | Install git or add to PATH |
| Lute stdio not capturing output | This is the root cause of PR #426/#444. Lute `process.run` behavior changed between versions. Check `.lute/build.luau` (grep `getCommitHash`) for how commitHash is extracted. | No assertion error raised but hash is empty | This is a Lute version bug. Check `rokit.toml`: is lute pinned to 1.0.0? If earlier version, update it. |
| Build not re-running after env change | Did you change `.env` and re-run the build? | No rebuild since .env change | Re-run: `lute run build plugin --channel dev --clean` |
| Prod channel overrides dev | Are you building prod? `--channel prod` doesn't use dev settings. | You built `--channel prod` instead of `--channel dev` | Use `--channel dev` for local development |

**Fix:** Ensure `.env` exists and has BASE_URL set. Re-run build with `--clean`. Verify `lute run build plugin --channel dev --clean` shows "BUILD_HASH = abc1234" in output.

**Escalation:** If Darklua still says BUILD_HASH is nil after rebuild, the issue is Lute's `process.run` stdio capture (rare). Upgrade Lute: `rokit install lute` (or manually edit `rokit.toml` to a newer version like 1.0.1+). If that doesn't work, file an issue on flipbook-labs/flipbook with `build/build-cache.json` output.

---

### 8. Windows Path-Length Errors

**Story:** PRs #518→#530 (the path-length saga) revealed that CI on Windows breaks on MAX_PATH (260 chars) even with OS-level long-path settings enabled — individual tools enforce their own hardcoded limits. The paths got that deep because Rotriever packaging layers a Wally-like structure on top of the already-huge `Packages/`/`RobloxPackages/` trees. PR #523 solved this by bundling `Packages/` and `RobloxPackages/` into `.rbxms` files before packaging for Rotriever consumption. Residue: the rbxm bundling code remains in `.lute/lib/build-system/compileAsync.luau` (grep `packToRbxm`).

**Symptom checklist:**
- Windows build fails with path length error (path > 260 chars).
- Error message mentions `_Index/` subdirs or nested `Packages/Packages/`.
- Only happens on Windows, not macOS/Linux.

**First check:**
```bash
# Check if you're on Windows
echo %OS% # Windows only
# or
uname -s # Unix-like (macOS/Linux)

# Verify rbxm bundling is in place
grep -A5 "Bundle up the gigantic" .lute/lib/build-system/compileAsync.luau
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Not on Windows | Run `uname -s` (macOS/Linux) or `echo %OS%` (Windows) | Darwin or Linux | You're on Unix; path length shouldn't be an issue. If error mentions paths, it's a different issue. |
| Rotriever target (Windows-specific) | Are you building `--target rotriever`? | Yes, rotriever build | This is expected; the rbxm bundling is active. Error should be resolved. If still failing, move to next step. |
| rbxm bundling not running | Check build output for "Bundle up the gigantic". Do you see it? | No message | Verify you're on main; rbxm bundling merged in PR #523. Merge main if on old branch. |
| Wally/Loom not synced | Run `lute run install` to regenerate packages. Check `Packages/_Index/` and `LuauPackages/` depths. | Multiple nested `_Index/` levels | Run install and rebuild. |
| Temp directory path is long | On Windows, if system temp dir is long (e.g., `C:\Users\YourVeryLongUsernameHere\AppData\Local\Temp`), intermediate artifacts may exceed 260 chars | Check `build/` and temp outputs | Move to a shorter path or use Windows junction: `mklink /J C:\short C:\Users\...\Temp` |

**Fix:** For Rotriever builds on Windows, ensure `lute run build plugin --target rotriever --clean` is used. The rbxm bundling is automatic. If paths still exceed limits after bundling, the issue is your system temp dir or IDE workspace path; shorten the path if possible.

**Escalation:** If path errors persist despite rbxm bundling, the issue may be a downstream tool (Rotriever, rojo) with its own path assumptions. Check error message for which tool/file path exceeded limits; if not rbxm bundling, escalate to that tool's repo.

**Verification:** PR #530 removed explicit path-length checking; the mitigation is implicit (rbxm bundling prevents deep nesting). No residue checks in `.github/actions/` (removed in #530).

---

### 9. Plugin Opening Uninvited

**Story:** PR #593 ("Try and stop Flipbook from popping up uninvited") fixed Studio layout reset triggering auto-launch. Root cause: `DockWidgetPluginGuiInfo.new()` with the InitialEnabled parameter set to `true` caused widget to re-enable on layout resets. Fix: changed to `false` and manually controlled open state via toolbar button.

**Symptom checklist:**
- After restarting Studio or resetting layout, Flipbook widget opens automatically without clicking the toolbar button.
- Studio output shows no error; widget just appears.

**First check:**
```bash
# Verify InitialEnabled is false
grep "DockWidgetPluginGuiInfo" src/PluginStarterScript.plugin.luau
```

Should show: `DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 800, 600)` where the second `false` is the InitialEnabled parameter.

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| InitialEnabled is true | Check `src/PluginStarterScript.plugin.luau` (grep `DockWidgetPluginGuiInfo`). What is the second bool argument? | Second bool is `true` | Change to `false` |
| Widget state is persisted in Studio settings | Delete Studio's plugin state: `~/Documents/Roblox Studio/` or plugin config dir. Restart Studio. | Widget doesn't auto-open after deletion | State was persisted. No fix needed; just cleared. |
| Toolbar button not wired | Check if toolbar button opens the widget: click it. Does widget appear? | No response | Verify `button:Click()` is connected to `widget.Enabled = true`. See `FlipbookCore.createFlipbookPlugin()` in `workspace/flipbook-core/src/`. |
| Dev build (with --watch) constantly reloading | Are you running `lute run build plugin --channel dev --watch`? Does that trigger re-opens? | Yes, watch rebuilds the plugin every few seconds | This is expected during watch. Stop the watch when not developing, or use `--skip-reload`. |

**Fix:** Verify the second boolean in `DockWidgetPluginGuiInfo.new()` is `false` in `src/PluginStarterScript.plugin.luau`. Re-build: `lute run build plugin --channel dev --clean`. Delete Studio cache if needed.

**Escalation:** If widget still auto-opens, the issue may be Studio itself persisting the widget state beyond the rebuild. Delete the `.rbxm` file from Studio plugins dir, restart Studio, rebuild, and reinstall.

---

### 10. Logs Not Appearing

**Story:** PR #484 ("Fix logs unintentionally routing to the Output window") fixed a 1-line bug where logs routed to Roblox Studio's output instead of the Flipbook Logs panel. Root cause was logger routing in `workspace/flipbook-core/src/logger.luau`. Today, logs are stored in LogsStore and displayed in `workspace/flipbook-core/src/Logs/LogsView.luau`. Visibility is controlled by two globals: `LOG_LEVEL` and `ENABLE_OUTPUT_LOGGING`.

**Symptom checklist:**
- Flipbook logs panel (Help > Logs) shows no entries.
- Or: logs appear in Roblox Studio Output window instead of Flipbook panel.
- Or: verbose logs (debug level) don't appear (filtering issue).

**First check:**
```bash
# Verify logger config
cat workspace/flipbook-core/src/logger.luau | head -40

# Check LOG_LEVEL env var
echo $LOG_LEVEL

# Check ENABLE_OUTPUT_LOGGING
echo $ENABLE_OUTPUT_LOGGING

# Verify Logs panel exists
ls workspace/flipbook-core/src/Logs/
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| LOG_LEVEL is too high (filters out messages) | If `LOG_LEVEL=error`, debug/info/warn messages are dropped. Set it to `info` or `debug`: `export LOG_LEVEL=debug` and rebuild. | Debug messages now appear | LOG_LEVEL was filtering. Use `debug` during development. |
| ENABLE_OUTPUT_LOGGING is true (spilling to Output) | Check `.env`: if `ENABLE_OUTPUT_LOGGING=true`, logs go to both LogsStore AND Roblox Output. | Logs appearing in Studio Output | Set to `false` if you want only Flipbook panel: `echo "ENABLE_OUTPUT_LOGGING=false" >> .env` and rebuild. |
| Logs panel not mounted | In Studio, do you see the Logs button/panel? | No Logs panel visible | Check `workspace/flipbook-core/src/FlipbookApp.luau` or `createFlipbookApp.luau` to verify LogsView is registered as a panel. |
| Logger not initialized in plugin context | The logger is defined in `workspace/flipbook-core/src/logger.luau` but must be required and used by plugin code. Are you actually calling the logger? | Code uses `logger:info()` but nothing appears | Verify the logger is instantiated: `local logger = require("@root/logger")` and used with `logger:info("message")`. |
| Build not re-run after env change | Did you change `.env` and rebuild? | No rebuild since .env change | Re-run: `lute run build plugin --channel dev --clean` |

**Fix:** Set `LOG_LEVEL=debug` (or appropriate level) in `.env`. Set `ENABLE_OUTPUT_LOGGING=false`. Rebuild: `lute run build plugin --channel dev --clean`. Logs should now appear in Flipbook's Logs panel.

**Escalation:** If logs still don't appear, check plugin code that calls the logger. If it's using the old Signals-based logger (pre-PR #509) or not importing from `@root/logger`, the log library isn't connected. Verify `logger.luau` is required in the entry point (`FlipbookApp.luau` or `createFlipbookApp.luau`).

---

### 11. Lute / Loom Toolchain Breakage After Version Bumps

**Story:** The stalled branch `upgrade-loom-dependencies` (last activity May 9 2026) attempted a Lute version bump and broke 10+ APIs. Changes like Lute's `process.run` stdio behavior or Loom's package-loading semantics are not backward-compatible. PRs #432–#433 (nightly publish) and #437 (work laptop) revealed brittleness.

**Symptom checklist:**
- After updating `rokit.toml` to a new Lute/Loom version, build fails with unfamiliar errors (e.g., "process.run returned nil", "Loom package not found").
- CI passes but local build fails (version mismatch).
- Scripts in `.lute/` fail with "attempt to call a nil value" (API changed).

**First check:**
```bash
# Check pinned versions
cat rokit.toml | grep -E "lute|loom"

# Verify tools are installed at pinned versions
rokit --version
lute --version

# Check if local version matches CI (look at .github/workflows/ci.yml)
grep -A2 "rokit install" .github/workflows/ci.yml
```

**Discriminating experiments:**

| Hypothesis | Experiment | Expected if TRUE | Next step |
|---|---|---|---|
| Lute version mismatch | Does `lute --version` match `rokit.toml`? | Versions differ | Run `rokit install` to sync to pinned version |
| API changed between Lute versions | Check Lute changelog (github.com/luau-lang/lute/releases). New version may have renamed/removed APIs. | Changelog shows breaking changes in `process.run` or `batteries.*` | Review `.lute/build.luau` and `.lute/lib/` for uses of changed APIs. Either downgrade Lute in `rokit.toml` or update the code. |
| Loom package loading changed | Does `.lute/lib/` use `require("@luaupkg/...")` patterns? | Yes; Loom's package lookup may have changed | Check `loom.config.luau` (defines package roots). Ensure `LuauPackages/` and `Packages/` directories exist and are in the Loom config. |
| CI has newer Lute, local has older | Check `.github/workflows/ci.yml` for Lute version pinning. Does it differ from `rokit.toml`? | CI pin is newer | Bump `rokit.toml` to match CI version; run `rokit install`. |
| Rollback needed | If the version bump is too painful, revert it. Old branch `upgrade-loom-dependencies` (6 commits, May 9) shows what was attempted. | Understand the scope of fixes needed | Either continue with the upgrade (implement all fixes) or revert to the previous Lute version in `rokit.toml`. |

**Fix:** Run `rokit install` to sync to pinned versions. If a tool version in `rokit.toml` has API breakage, either update the `.lute/` scripts to the new API (consult the tool's changelog), or downgrade the tool version in `rokit.toml` and re-run `rokit install`.

**Escalation:** If upgrading Lute requires rewriting multiple scripts, consider deferring the upgrade until the new API is stable (Lute is young software). For now, keep pinned version at a stable release. If you must upgrade, create a separate branch, implement all fixes, and test thoroughly in CI before merging.

---

## Cross-Cutting Diagnostics

### How to read the build cache
```bash
cat build/build-cache.json
```
This JSON contains:
- `env`: injected globals (BUILD_VERSION, BUILD_HASH, BUILD_CHANNEL, BUILD_TARGET, BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING, JEST_TEST_PATH_PATTERN)
- `members`: workspace members (flipbook-core, test-runner, example, etc.) with their source mtimes
- `dependencies`: Wally+Loom package hashes

If cache shows old mtimes or missing members, a `--clean` rebuild regenerates it.

### How to inspect the sourcemap
```bash
# View sourcemap (maps Luau module paths to Roblox instance paths)
cat build/sourcemap-darklua.json | jq '.name2path["@workspace/flipbook-core/src/FlipbookApp"]'
```

### How to check if watch is running
```bash
# Terminal 1: run watch
lute run build plugin --channel dev --watch

# Terminal 2: edit a file and check for output
echo " " >> workspace/flipbook-core/src/StoryView.luau
# Look in Terminal 1: should see "Compiling workspace/flipbook-core"
```

### Lute / Loom version reporting
```bash
lute --version
loom --version  # if installed
rokit list
```

---

## Provenance and Maintenance

**Commands to re-verify when context drifts:**

- `lute run build plugin --channel dev --clean` — verify help output still shows --channel, --target, --clean flags: `lute run build plugin --help`
- `cat .darklua.json` — confirm inject_global_value rules still include BUILD_HASH, BUILD_VERSION, BASE_URL, LOG_LEVEL, ENABLE_OUTPUT_LOGGING, JEST_TEST_PATH_PATTERN
- `ls build/sourcemap-darklua.json` — after any rebuild; if file missing, Rojo step failed
- `grep "Charm.flags.frozen" src/PluginStarterScript.plugin.luau` — this line is permanent (storyteller#100); if absent, add it back immediately
- `cat .env.template | grep -E "BASE_URL|LOG_LEVEL|ENABLE_OUTPUT|ROBLOX"` — verify env template still defines these vars
- `rokit.toml` pinned versions — check if Lute, Darklua, Rojo versions have known issues; consult GitHub releases if build behavior changes

**Last verified:** 2026-07-01 against commit 78d71e8f. Sourcemap paths, build cache format, logger routing (PR #484), Charm workaround (story#100), Logs panel structure all confirmed current.

