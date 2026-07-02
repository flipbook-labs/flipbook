---
name: flipbook-diagnostics-and-tooling
description: "Instrumentation and observability: how to measure Flipbook's runtime behavior. Use when: debugging why a story doesn't load (add logging), validating a performance fix (measure rerenders), verifying build inclusion (inspect sourcemaps/cache), or filtering tests. Covers logging system, test output parsing, build-cache inspection, sourcemap require-path tracing, and rerender accounting. Complements flipbook-validation-and-qa (evidence standards for fixes) by providing the measurement tools."
---

# Flipbook Diagnostics & Tooling

Measure Flipbook behavior instead of eyeballing. This skill teaches how to instrument and inspect the Flipbook system at runtime and build time: the logging system, test filtering and output interpretation, build-cache introspection, sourcemap inspection for require-path debugging, and rerender measurement for performance regression detection. Includes runnable scripts for automated analysis.

**Scope:** This skill is for observability and measurement. **Use this when:** you need to measure/instrument to *find* a bug, verify build inclusion, or validate that instrumentation is working correctly.

**Do NOT use this skill when:** you need to *prove* a fix is correct (→ `flipbook-validation-and-qa`), understand architecture (→ `flipbook-architecture-contract`), debug build/Darklua mechanics (→ `flipbook-build-and-toolchain`), or triage a runtime symptom (→ `flipbook-debugging-playbook`).

## The Logging System

Flipbook uses the `Log` library (Wally dep) to route log messages to two configurable sinks: an in-plugin Logs view (always on) and the Roblox Studio Output window (opt-in).

### Log Levels and Configuration

The log level is controlled by the `LOG_LEVEL` environment variable (defined in `.env.template`), which is injected into `_G.LOG_LEVEL` at build time via Darklua. The values are case-sensitive strings mapping to the Log library's enums:

- `"debug"` — Log.LogLevel.Debugging (most verbose; internal state changes, function entry/exit)
- `"info"` — Log.LogLevel.Information (default; feature-level messages, story loaded, control changed)
- `"warn"` or `"warning"` — Log.LogLevel.Warning (alerts; deprecated patterns, missing optional fields)
- `"err"` or `"error"` — Log.LogLevel.Error (errors only; failed operations, invalid states)

Unrecognized strings default to Warning. The log-level filtering happens at the Log library level in `workspace/flipbook-core/src/logger.luau` (lines 5–16).

### Output Routing

The logger has two sinks, both instantiated in `logger.luau` (lines 18–26):

1. **In-Plugin Logs View (always active)**: Captured by a LogSink that calls `LogsStore.get().addLine(event)`, which appends to the Logs panel visible in Flipbook's Help menu.
2. **Roblox Output Window (opt-in)**: Only added when `_G.ENABLE_OUTPUT_LOGGING == "true"` (line 24). This lets you see logs in Studio's Output tab for easier copy-paste and search.

Set `ENABLE_OUTPUT_LOGGING=true` in `.env` (or via Darklua override) to enable Output window logging. The default is false to keep Studio's Output clean during normal plugin use.

### Log Enrichers and Filtering

The logger applies two enrichers to every log event (lines 30–32):
- `LogLevelEnricher()`: adds human-readable level name to each event
- `DynSourceEnricher(true)`: adds source file + line number where the log call originated (expensive; the `true` flag enables dynamic source tracking)

The `MinLevelFilter` (lines 35–36) gates events below the configured level; only matching events reach the sinks.

### Adding Log Lines in Code

To add a log statement in Flipbook code:

```luau
local logger = require("@root/logger")
logger:info("Story loaded: {}", storyName)
logger:warn("Control missing default value")
logger:error("Failed to render component: {}", errorMsg)
```

The logger is already injected into most workspace components. Use the `:info()`, `:warn()`, `:error()`, `:debug()` methods with printf-style formatting (e.g., `{}` for substitution).

### Debugging Sessions with Logging

When debugging a runtime issue:

1. Set `LOG_LEVEL=debug` in `.env` and rebuild: `lute run build plugin --channel dev`. This captures every state change.
2. Open Flipbook in Studio and perform the steps that trigger the issue.
3. Open Help > Logs view in the Flipbook plugin. Scroll to the relevant time window. Look for ERROR or WARN lines first, then trace backwards through the INFO/DEBUG messages to see what state led to the failure.
4. If you need Output window logs, also set `ENABLE_OUTPUT_LOGGING=true` and check Studio's Output tab. The output window is useful for searching or copying log text to share.
5. If the issue reproduces reliably, use `grep` on `workspace/flipbook-core/src/logger.luau` to find where similar messages are logged, then add more verbose logging around that codepath.

Example: debugging a story that doesn't load. Set `LOG_LEVEL=debug`, trigger the story load, and search Logs for messages containing the story name or "Story". The log sequence will show discovery → validation → rendering steps.

## Test Filtering and Cloud-Test Output Interpretation

Tests are run via `lute run test`, which builds a dev plugin, packs a Roblox place with Jest test runner, uploads it to Roblox cloud infrastructure (Rocale/Luau Execution), and runs tests in that sandboxed cloud place. The process requires `ROBLOX_API_KEY` environment variable.

### Running Tests with Filters

The basic test command is:

```bash
lute run test
```

To run only tests matching a specific pattern (Jest testPathPattern):

```bash
lute run test --filter "MyComponent"
```

The `--filter` argument is injected into `JEST_TEST_PATH_PATTERN` env var by `.lute/test.luau` (line 39), which is then injected by Darklua into `_G.JEST_TEST_PATH_PATTERN` at build time. The test runner (in `workspace/test-runner/src/init.luau`) reads this global and passes it to Jest as `testPathPattern = _G.JEST_TEST_PATH_PATTERN`.

Jest matches the pattern against spec file paths relative to the repo root. So `--filter "StoryControls"` will run `createStoryControlsStore.spec.luau`, `StoryControlRow.spec.luau`, etc.

### Understanding Rocale Cloud Test Output

Rocale is Roblox's cloud test executor. When you run `lute run test`, the flow is:

1. `.lute/test.luau` builds a dev plugin and packs test place into a temporary rbxl file (line 62–61)
2. Rocale invokes `.lute/tasks/run-tests.luau` script in that cloud place, passing API key and place IDs (lines 63–79)
3. `run-tests.luau` requires the test runner from ReplicatedStorage and calls `TestRunner.runTests()` (lines 4–6)
4. Jest runs all matching specs and logs output via the Rocale stdout/stderr

The output format is Jest's standard TAP (Test Anything Protocol) with colored PASS/FAIL per test file. Look for:

- `✓ (N passed)` — suite passed, N tests all succeeded
- `✕ (N failed)` — suite failed; see details below
- `● (test name)` — individual test failure; stack trace shows assertion or error
- `Test Suites: (X passed), (Y failed)` — summary line at end

Common failures:

- **Test file itself failed to load** (syntax error, missing require): `require("@root/MyModule") is nil` → module not in build or path typo
- **Assertion failed**: `expect(...).toBe(...)` failed; check the expected vs actual values above the stack
- **Timeout**: test took longer than Jest's default 5000ms; add `jest.setTimeout(10000)` at top of spec
- **Cannot connect to Roblox service**: Usually means the test is trying to access Studio APIs that don't exist in cloud; wrap in `if game.Settings.Studio then ... end`

### Filtering and Failure Examples

To debug a specific failing test:

```bash
lute run test --filter "StoryControls\.spec"
```

This runs only `StoryControls.spec.luau`. The output will show which specific test(s) in that file failed.

If all tests pass locally but CI fails, the issue may be environment-specific (API key, place setup, or test-runner version mismatch). Compare your local `.env` with the CI environment secrets (in `.github/workflows/strict.yml`).

## Build Introspection: build-cache.json

The build cache at `build/build-cache.json` is a JSON map tracking which workspace members have been built and their content hashes. Each key is a tuple `{channel}-{target}-{workspace-path}`, and the value is an MD5 hash of the workspace member's source files.

### Anatomy of build-cache.json

Example entries (from current build):

```json
{
  "dev-roblox-/Users/marin/Code/flipbook/workspace/flipbook-core": "509bd83fc9af3035d1e6e77d7babdc00",
  "prod-roblox-/Users/marin/Code/flipbook/workspace/flipbook-core": "1512d11c525767b2b5d6aa360790995d",
  "prod-rotriever-/Users/marin/Code/flipbook/workspace/flipbook-core": "966fa679d182a4b3f1119d9881f3471a"
}
```

The keys show:
- `dev` or `prod` channel (dev keeps stories/specs, prod prunes them)
- Target: `roblox` (in-Studio) or `rotriever` (package format)
- Full absolute path to workspace member

The hash reflects the workspace member's input (source + dependencies), not the output. If the hash hasn't changed since the last build, incremental rebuild skips that member.

### Checking What Was Built

To verify what the most recent build included:

```bash
cat build/build-cache.json | jq 'keys[] | select(contains("flipbook-core"))'
```

This lists all cache entries for flipbook-core across all channels/targets. If you built `dev` channel, you'll see entries with `dev-roblox-` prefix. If you built `prod` for release, you'll see `prod-roblox-` and `prod-rotriever-` entries.

To check if a workspace member was rebuilt (cache miss), note its hash before and after running `lute run build plugin --channel dev`. If the hash differs, the member was recompiled.

The build system (`.lute/lib/build-system/compileAsync.luau`) reads this cache at build start and compares hashes. Hash mismatches trigger full recompilation of that member and any dependents.

### Interpreting Cache Misses

A cache miss means the workspace member's source changed. Common causes:

- You edited a source file (expected)
- A dependency version changed (Wally or Loom)
- Env vars injected by Darklua changed (e.g., LOG_LEVEL), requiring rebuild
- The cache file was corrupted or lost (rare; rebuild from scratch with `--clean`)

If a build takes longer than expected, check the cache: `cat build/build-cache.json | wc -l`. Many entries (50+) suggest all members were rebuilt (likely `--clean` flag or cache wipe).

## Sourcemap Inspection for Require-Path Debugging

Darklua converts Luau-style string requires (e.g., `require("@workspace/flipbook-core/src/logger")`) to Roblox's hierarchical require format using sourcemaps. A sourcemap is a JSON file mapping original require paths to Roblox instance paths.

### Sourcemap Files

Two sourcemaps are active:

- `sourcemap.json` (root): maps root-level requires to instances
- `workspace/flipbook-core/sourcemap.json`: maps flipbook-core workspace member requires
- `sourcemap-darklua.json`: Darklua's output after resolving all requires through Rojo

These are generated by Rojo (during `rojo sourcemap` step) and consumed by Darklua to transform source code before packaging.

### Checking a Require Path Resolution

To verify a module's require path resolved correctly in the build:

1. Open the built module in `build/dev/roblox/workspace/flipbook-core/src/Common/InstancePicker.luau` (or the path of interest)
2. Check if the file exists and contains the expected code (e.g., search for a key function name)
3. Look at any require statements in that file. For example, if the original source has `local React = require("@pkg/React")`, the built version should have `local React = require(ReplicatedStorage.Packages.React)` (or similar hierarchical path)

To debug a "module not found" error:

```bash
grep -r "InstancePicker" build/dev/roblox/
```

If the file doesn't appear in build output, the module was pruned (e.g., if it's in the `code-samples` dir and you built `prod` channel, it's excluded by `PROD_CONFIG.prunedDirs` in `project.luau`).

If the file exists but isn't being required correctly, check:

1. The original require path spelling (typo in `@workspace/` vs `@pkg/`)
2. The sourcemap entry exists: `grep "InstancePicker" sourcemap.json`
3. Re-build with `--clean`: `lute run build plugin --channel dev --clean`

### Verifying Injected Globals in Built Output

Globals injected by Darklua (BUILD_VERSION, LOG_LEVEL, etc.) appear in the built output as literal values. To check if a global was injected:

```bash
grep -n "_G.LOG_LEVEL\|_G.BUILD_VERSION" build/dev/roblox/workspace/flipbook-core/src/logger.luau
```

If you see `_G.LOG_LEVEL = "info"` (a literal value), injection succeeded. If you still see `_G.LOG_LEVEL` (undefined global), the injection failed; check `.darklua.json` and rebuild with `--clean`.

This is a safe, read-only inspection — never edit the built output directly.

## Rerender Measurement: Validating Story Control Performance

The PR #576 fix for story-control re-rendering (referenced in the brief's archaeology section) introduced per-control signal subscriptions to prevent the entire panel from re-rendering when one control changes. To verify this behavior in a story, you can instrument a control component with a render counter.

### Setting Up a Render Counter in a Story

A render counter is a React effect that increments a local state variable every time a component renders. This lets you see how many times a component re-renders as you interact with its controls.

Example story demonstrating render isolation (add to `workspace/flipbook-core/src/StoryControls/StoryControls.story.luau` or create a new story):

```luau
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local StoryControls = require("./StoryControls")
local StoryControlsContext = require("./StoryControlsContext")

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect

local function RenderCounter(props)
	local renderCount, setRenderCount = useState(0)

	useEffect(function()
		setRenderCount(renderCount + 1)
	end, {})

	return React.createElement(
		"TextLabel",
		{
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			Text = props.name .. " renders: " .. renderCount,
		}
	)
end

return {
	summary = "Measure control re-renders to validate PR #576 isolation",
	story = function()
		local controlsSchema = useMemo(function(): Storyteller.StoryControlsSchema
			return {
				text = Storyteller.createStringControl("default"),
				number = Storyteller.createNumberControl(),
			}
		end, {})

		return React.createElement(
			StoryControlsContext.StoryControlsProvider,
			{ schema = controlsSchema },
			React.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
				},
				React.createElement(RenderCounter, { name = "TextControl" }),
				React.createElement(RenderCounter, { name = "NumberControl" }),
				React.createElement(StoryControls, { controlsSchema = controlsSchema })
			)
		)
	end,
}
```

When you preview this story and interact with the text control, you should see:
- `TextControl renders: 2` (or higher, initial mount + user edit)
- `NumberControl renders: 1` (unchanged; only mounted once)

If NumberControl's render count increases when you change TextControl, the per-control isolation is broken (regression of PR #576).

### Running the Test

1. Build dev plugin: `lute run build plugin --channel dev`
2. Open the story in Flipbook
3. Change the text control value
4. Observe render counts in the story (update live as you type)
5. Verify that changing one control does not increment other controls' render counts

This validates that the store subscription model (per-control signals via `useSignalState`) is working correctly.

## Diagnostic Scripts

The `scripts/` directory in this skill contains three read-only analysis scripts. All scripts run without modifying the repo.

### inventory-stories.sh

Lists the count of stories and specs per workspace member.

**Usage:**
```bash
bash .claude/skills/flipbook-diagnostics-and-tooling/scripts/inventory-stories.sh
```

**Output:**
```
=== Flipbook Story & Spec Inventory ===

Workspace Member                  Stories      Specs
----------------------------------------------------
code-samples                           10          0
example                                16          0
flipbook-core                          23         16
----------------------------------------------------
TOTAL                                  49         16
```

**Purpose:** Verify test coverage growth. Run before and after adding new specs; compare the TOTAL line. Useful for PR reviews to ensure new features have corresponding tests.

### detect-env-drift.sh

Scans source code for `process.env.VAR_NAME` reads and compares them against variables declared in `.env.template`.

**Usage:**
```bash
bash .claude/skills/flipbook-diagnostics-and-tooling/scripts/detect-env-drift.sh
```

**Output:**
```
=== Environment Variable Drift Detection ===

⚠️  UNDECLARED (used in code but not in .env.template):
  JEST_TEST_PATH_PATTERN (used 1 times)

ℹ️  UNUSED (in .env.template but never read in code):
  (none)

Summary: 6 env vars declared, 6 vars read from code
❌ Drift detected
```

**Purpose:** Catch missing or stale environment variable declarations. If you add a new feature that reads a new env var (e.g., `process.env.MY_NEW_VAR`), this script will flag it as UNDECLARED. Add it to `.env.template` to fix the drift.

**Interpreting Results:**

- **UNDECLARED**: Code references an env var not in `.env.template`. Add the var to `.env.template` with a comment explaining its purpose.
- **UNUSED**: `.env.template` has a var that no code reads. Either it's legacy (safe to remove) or the code path is dead. Check git history for context before deleting.

### check-sourcemap-freshness.sh

Verifies that sourcemap files were generated after the latest source file they map.

**Usage:**
```bash
bash .claude/skills/flipbook-diagnostics-and-tooling/scripts/check-sourcemap-freshness.sh
```

**Output:**
```
=== Sourcemap Freshness Check ===

✅ workspace/flipbook-core: sourcemap is fresh
✅ root project: sourcemap is fresh

✅ All sourcemaps are fresh
```

Or if rebuild is needed:

```
❌ workspace/flipbook-core: sourcemap older than source
✅ root project: sourcemap is fresh

⚠️  Some sourcemaps may be stale — rebuild with: lute run build --clean
```

**Purpose:** Detect out-of-sync sourcemaps, which cause require-path mismatches. If you edit source files and then run a build without rebuilding sourcemaps (e.g., partial rebuild), the sourcemap becomes stale. This script catches that. Run it after pulling new commits or making manual source changes.

**Typical Workflow:**

1. Pull new changes or edit source files
2. Run: `bash scripts/check-sourcemap-freshness.sh`
3. If stale, rebuild: `lute run build plugin --channel dev --clean`
4. Re-run the script to confirm freshness

## Putting It All Together: A Debugging Checklist

When diagnosing a runtime issue in Flipbook:

1. **Enable debug logging**: Set `LOG_LEVEL=debug` and `ENABLE_OUTPUT_LOGGING=true` in `.env`, rebuild, reproduce the issue.
2. **Check Logs view**: Help > Logs (in Flipbook). Search for ERROR or WARN lines; trace backwards.
3. **Check build freshness**: Run `check-sourcemap-freshness.sh` to rule out stale compilation artifacts.
4. **Run story-specific tests**: Use `lute run test --filter "YourStory"` to isolate test failures.
5. **Inspect build output**: Use `grep` to verify a module exists in `build/dev/roblox/` and has correct require paths.
6. **Measure performance**: Use a render counter in the story to verify controls aren't re-rendering excessively.
7. **Check env drift**: Run `detect-env-drift.sh` to rule out missing configuration.
8. **Inventory coverage**: Run `inventory-stories.sh` before and after adding a feature to track test growth.

## Provenance and Maintenance

- Log levels and sinks: Read `workspace/flipbook-core/src/logger.luau` annually. Change log level defaults if performance needs shift.
- Test filtering: Verify with `lute run test --filter "test" --help` and `.lute/test.luau` that the filter parameter is still injected as `JEST_TEST_PATH_PATTERN`.
- Build cache: Check `build/build-cache.json` structure in `.lute/lib/build-system/compileAsync.luau` (hashing logic).
- Sourcemaps: Rojo generates these; verify path with `.darklua.json` field `"rojo_sourcemap"`.
- Rerender behavior: Verify PR #576's per-control store isolation still exists in `workspace/flipbook-core/src/StoryControls/createStoryControlsStore.luau` and `StoryControlsContext.luau`.
- Scripts: Test with `bash scripts/inventory-stories.sh`, `bash scripts/detect-env-drift.sh`, `bash scripts/check-sourcemap-freshness.sh` monthly to catch regressions.
