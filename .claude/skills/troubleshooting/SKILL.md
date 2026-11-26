---
name: troubleshooting
description: "Non-obvious Flipbook runtime and build failures, the past incidents you should not redo, and the measurement techniques that settle build questions. Use when: the Studio plugin is stale after a rebuild, an injected global (BUILD_HASH, BASE_URL, LOG_LEVEL) is nil or wrong, the plugin opens uninvited, tests fail or wait on a fork PR, a build or Rotriever bundle breaks on Windows, you are about to parallelize the build, patch a package, or touch pull_request_target, or you need to prove a build change or a re-render fix with evidence."
---

# Troubleshooting

Flipbook's root `AGENTS.md` covers the commands and the Charm workaround. This skill holds what the code does not tell you: why a symptom happens, which past attempts failed, and how to measure instead of guess.

## Symptom to cause

**Studio still runs old code after a rebuild.** Check three things in this order. `lute run build` defaults to `--channel prod`, which strips stories and sets the production channel, so pass `--channel dev`. `--skip-reload` does not just skip the reload: when the output is the Studio plugins folder, the script never copies the new `Flipbook.rbxm` there. Then suspect the cache (next entry).

**A baked value is stale: `_G.LOG_LEVEL`, `_G.BASE_URL`, or the hash shown in the About panel.** The build cache in `build/build-cache.json` stores a content hash of each workspace member directory, not file times. A member is recompiled only when its own files change or you pass `--clean`. Editing `.env` or making a new commit changes no member file, so member code keeps the old literals. The root `src/PluginStarterScript.plugin.luau` is processed on every build, so the `Flipbook [hash]` plugin name can be fresh while the About panel is not. Use `--clean` after any `.env` change.

**An injected global is nil at runtime.** Darklua substitutes the value at build time and prints a `WARN` that the environment variable is not defined, then uses `nil`. The build still succeeds. `BASE_URL`, `LOG_LEVEL`, and `ENABLE_OUTPUT_LOGGING` come from `.env` through the process environment, so a missing `.env` is the usual cause. `lute run build` stops when `BASE_URL` is unset, but it does not check `LOG_LEVEL` or `ENABLE_OUTPUT_LOGGING`. Copy `.env.template` to `.env` and rebuild with `--clean`.

**Logs appear in Studio Output, or do not appear in Help > Logs.** `ENABLE_OUTPUT_LOGGING` is compared as the string `"true"` in `workspace/flipbook-core/src/logger.luau`, and `LOG_LEVEL` filters before either destination. Both are baked in, so changing them needs a rebuild.

**Studio reports a missing `@pkg` or `@workspace` alias.** Darklua left a string require unresolved, so the plugin carries a Luau-style path that Roblox cannot load. Causes are a stale `sourcemap-darklua.json` or an absolute source path handed to Darklua. The build regenerates the sourcemap with Rojo and passes a relative path. If you changed `compileAsync.luau`, keep both.

**Flipbook opens by itself after a Studio restart or layout reset.** The dock widget must be created with `InitialEnabled = false`. See `DockWidgetPluginGuiInfo` in `src/PluginStarterScript.plugin.luau`. Commit `e62eb043` (#593) made this change after users reported the widget reopening whenever Studio lost its layout state.

**Story preview crashes with "attempt to modify a readonly table".** Someone removed `Charm.flags.frozen = false`. Put it back and see the root `AGENTS.md`.

**Jest suites fail to load in the cloud with a "MainGui not found" assertion.** Foundation modules create instances at require time and expect `getMainGui` to return something. Headless Rocale sessions have no GUI. `.lute/install.luau` patches this (grep `patchFoundationMainGui`). If a Foundation upgrade brings back the failure, the patch no longer matches. Do not add more patches (see the history entry below).

**Tests never start on a fork PR.** `.github/workflows/strict.yml` runs the `tests` job in the `luau-execution-gated` environment for fork PRs, which waits for a maintainer approval. Same-repo PRs use `luau-execution`. Locally, `lute run test` needs `ROBLOX_API_KEY` and always does a clean dev build first, so `--filter` also rebuilds.

**A new build channel fails to deploy.** Channels map to asset names in `creator-store.luau` at the repo root, which defines only `Prod`, `Dev`, and `Smoketest`. The beta channel reuses the `Dev` asset through `ASSET_NAMES_BY_CHANNEL` in the same file. A channel without an entry there fails at publish time, not at build time (#596, `0d045ce9`).

## Do not repeat

**Windows path length and `packToRbxm`.** Consuming the Rotriever bundle on Windows hit the 260 character limit because Rotriever's own `Packages\_Index\FlipbookCore\FlipbookCore` prefix, a CI workspace prefix, and Wally's nested `_Index` all stack. Enabling OS long-path support does not help because individual tools enforce their own limit. PR #518 added a path-length check, #523 (`7a6c69b5`) fixed the cause by packing `Packages/` and `RobloxPackages/` into `.rbxm` files with `.lute/lib/packToRbxm.luau`, and #530 deleted the check as redundant. Keep the `packToRbxm` loop in the Rotriever branch of `compileAsync.luau`. Do not rewrite the bundle layout or bring the check back.

**Parallel builds.** `Parallelize build tasks` (#405, `1cd83177`) was reverted the next day (`68b0e2f4`) with no explanation. The build runs strictly in sequence. `.lute/lib/waitForTasks.luau` survives but nothing calls it. Process spawning through Lute was already fragile, so measure with a clean sequential build before proposing this again.

**Rotriever bundle manifest.** The first attempt at this (`389a0891`) was reverted (`2626cdae`) and then landed properly in #584 (`60fc52eb`). The bundle step now copies `workspace/flipbook-core/rotriever.toml` directly, and its `content_root` is `src`. Searching the build output for any `rotriever.toml` picked up TestEZ's manifest instead. Treat the current layout as settled.

**`BUILD_HASH` going missing.** It broke twice, in #426 (`1863e994`) and #444 (`704fbd5b`), six weeks apart. Both times the cause was how Lute's process stdio is configured differing between Lute versions, so `git rev-parse` returned nothing. `getCommitHash()` in `.lute/build.luau` now captures output and asserts it is not empty. If the build fails with `commit hash is empty`, the Lute process API changed, so look at the `run` helper before the git call. Expect the same class of break from any Lute bump, because the `.lute/` scripts and the Loom packages they require all depend on Lute's process and filesystem APIs.

**Missing `BASE_URL` in CI.** Nightly builds shipped a nil URL because CI never copied `.env.template` to `.env` (#479, `d313d7b6`). Every workflow step that builds the plugin copies the template first, and the build guard enforces it. A new workflow needs the same step.

**Darklua and absolute paths.** `Fix broken nightly build` (#535, `8c386f75`) found that Darklua does not resolve string requires when given an absolute input path. The comment in `compileAsync.luau` records the workaround. Passing `--absolute` to `rojo sourcemap` did not help, so do not try it again.

**`pull_request_target`.** Fork support (#559) switched the whole CI workflow to `pull_request_target`, which then deployed dev builds from every PR (#561) and checked out the wrong code for tests. #563 (`5c997592`) and #562 (`64ed0047`) moved the secret-requiring work into `strict.yml`. That workflow builds PR code on a runner with no secrets and hands only build artifacts to the gated jobs, which check out the base commit. Keep that split. Never run PR code in a job that has `ROBLOX_API_KEY`, and never make a release or deploy job depend on `pull_request_target`.

**Package patching.** Install-time patches exist for three reasons: string requires in `charm` and `react-charm` (`patchStringRequires`), Roact and React linkers pointing at Flipbook's own copies, and the Foundation MainGui fix from #666. The Foundation patch unblocked the RobloxPackages 0.747 upgrade and is the exception, not a pattern. For an upstream bug, fix it in Flipbook code if you can. Otherwise write up an upstream report and ask before adding another patch.

## Measure instead of guessing

**Grep build output for the value, not the global.** `inject_global_value` replaces every `_G.NAME` read with a literal, and `compute_expression` plus `remove_unused_if_branch` fold the branches around it. In a built file, `_G.BUILD_CHANNEL == "development"` is gone. A dev build contains `_G.__DEV__ = true` unconditionally, and a prod build contains no `__DEV__` at all:

```bash
grep -n "__DEV__" build/dev/roblox/PluginStarterScript.plugin.luau
grep -n "__DEV__" build/prod/roblox/PluginStarterScript.plugin.luau
grep -n "PLUGIN_NAME" build/dev/roblox/PluginStarterScript.plugin.luau
```

The same applies to your own change. Search the built output for the literal you expect, or for the absence of the branch you expect to be pruned. A passing build does not tell you Darklua processed anything. For a member file, look under `build/<channel>/<target>/workspace/<member>/src`.

**Check what the build cache believes.** `build/build-cache.json` maps `<channel>-<target>-<path>` to an MD5 of file contents. If a change did not reach the artifact, delete that one key or run `--clean`. Do not reason about timestamps.

**Count renders in the render body.** Claims such as "changing one control no longer re-renders the others" need a number. The isolation lives in `StoryControls/createStoryControlsStore.luau` and `StoryControlRow.luau`. Temporarily add a counter at the top of the component function, build with `--channel dev`, and run a fixed sequence in a story:

```luau
-- module level, above StoryControlRow. Delete before committing.
local renderCounts: { [string]: number } = {}

-- first line inside StoryControlRow
renderCounts[props.controlName] = (renderCounts[props.controlName] or 0) + 1
print("[renders]", props.controlName, renderCounts[props.controlName])
```

Toggle one control a fixed number of times and compare the per-row totals before and after your change. A counter placed in `useEffect` with an empty dependency list counts mounts, not renders, so it cannot show a regression. Use `print` for this, because `logger` output goes to Help > Logs unless `ENABLE_OUTPUT_LOGGING` is `true`.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
git grep -n "Charm.flags.frozen = false" -- src
git grep -n -E "patchFoundationMainGui|patchStringRequires" -- .lute
git grep -n getCommitHash -- .lute
git grep -n ENABLE_OUTPUT_LOGGING -- workspace
```
