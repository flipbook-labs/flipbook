---
name: dev-env
description: "Set up, repair, and validate the Flipbook, Storyteller, and ModuleLoader development environment. Covers dependency installs, .env, lint, analyze, and cloud tests (which need an Open Cloud key), testing local Storyteller or ModuleLoader changes inside Flipbook with the try-in scripts, verifying through StudioPlugins, and what counts as evidence that a fix works. Use when: first-time setup, tooling or packages look stale, running checks, tests cannot run, testing a Storyteller or ModuleLoader change in Flipbook, or deciding whether you have proven a fix."
---

# Dev Environment

Flipbook's `AGENTS.md` lists the tools and the common commands. This skill covers what it leaves out.

## Setup and repair

Run `rokit install` and then `lute run install` from the repo root. Copy `.env.template` to `.env` in Flipbook before building. The build fails without `BASE_URL`, and `lute run test` reads the Open Cloud values from the same file.

`Packages/`, `RobloxPackages/`, `.lpm/`, `.env`, and `build/` are all gitignored. A new worktree starts with none of them, so run the install and create `.env` again in each one. Never edit them by hand.

`lute run install` also patches some third-party packages after fetching them, so a hand-edited `Packages/` does not survive it.

If `lute run` reports unresolved imports, rerun `lute run install`. It vendors the Lute packages from `pkg.luau` into `.lpm/<key>@<rev>`, so a missing or stale folder shows up as a failed `require` of an `@lpm/` module. That happens in a fresh worktree, or after a `rev` changes in `pkg.luau`. If rokit fails with "No such file or directory (os error 2)", it is invoking a tool it has not installed. Run `rokit install`.

## Checks

Run `lute run lint`, `lute run analyze`, and `lute run test` from the repo root. Storyteller and ModuleLoader have the same three scripts. If analyze reports missing sourcemap or alias errors, rerun the install first.

`lute run test` builds a dev plugin, packs a test place, and runs Jest in Roblox's cloud through Rocale. Nothing runs locally, so the test needs an Open Cloud key with Luau Execution access. Supply it as `ROBLOX_API_KEY` in `.env` or with `--apiKey`. The place and universe IDs are already in `.env.template`.

Useful flags:

- `--filter <pattern>` runs only specs whose path matches.
- `--build-only` and `--run-only` split the build from the cloud run, with `--place` naming the file in between.

In Flipbook, `lute run check` runs the path a fork author has without a key: `changewrite check`, `lute setup`, lint, analyze, and a dev plugin build to a temporary file. Use it as the default local check for a contribution.

### When the key is missing

Do not claim the change is tested. Run `lute run check` in Flipbook, or lint and analyze in Storyteller and ModuleLoader, and say in the PR that the cloud tests did not run and why. List what you ran in their place. Neither lint nor analyze proves behavior, so for anything beyond a rename or a typo, say so plainly. CI runs the cloud tests with its own key, and for fork PRs a maintainer approves that run.

## Testing Storyteller or ModuleLoader changes in Flipbook

Wally resolves only from its registry, so Flipbook cannot depend on a local checkout. The `try-in-flipbook` script in each dependency repo is the workaround. It deletes the `dist/` folder inside the installed package under `Packages/_Index`, runs `lute run build`, and copies the fresh `dist/` over it.

- Storyteller: run `lute run try-in-flipbook` in the Storyteller repo.
- ModuleLoader: run `lute run try-in-flipbook` in the ModuleLoader repo. To test it through Storyteller as well, run `lute run try-in-storyteller` there first, then `try-in-flipbook` in Storyteller.

Then rebuild Flipbook with `lute run build plugin --channel dev --clean`, or run `lute run test`, which rebuilds on its own.

Three things trip this up:

- The scripts find Flipbook as a sibling directory named `flipbook`. They write to that checkout, not to a worktree of it. To test from a worktree, copy the built `dist/` into that worktree's own `Packages/_Index` entry.
- Flipbook's `lute run install` runs `wally install` again and discards the overlay. Overlay after installing, never before.
- The overlay builds with the default prod channel. The overlaid package therefore has no tests or stories.

## StudioPlugins

Do this only when the engineer asks. It tests FlipbookCore inside the StudioPlugins Flipbook plugin. Build the bundle with `lute run build --target rotriever --clean`. The output lands in `build/flipbook-core-rotriever`. The engineer points StudioPlugins at that path and runs its watcher. Rebuild the bundle after each change and let the watcher reload the plugin. Ask the engineer for the StudioPlugins build command rather than guessing it.

## What counts as evidence

A fix is proven by a spec that fails without the change and passes with it. If the area has no spec, a recorded manual recipe in Studio with concrete observations is the fallback. Passing tests alone do not prove the fix, since they show only that nothing existing broke. Reading the code and judging it correct is not evidence either.

Cloud tests cannot see a failure in `ContextProviders`. React's error boundary catches the error, the test sees an empty tree, and the test passes. A `FIXME` in `createFlipbookApp` marks this gap. If you change context providers or app startup, open the built plugin in Studio and confirm the UI renders with no errors in Output.

Tests also cannot see visual changes. Jest renders to Instances, not pixels, so check layout, color, and font changes in Studio.

## Re-verify

**Re-verify these claims when this skill next loads.** Run these from the repo root. A command that fails or prints nothing means the skill needs updating:

```sh
ls .lute/install.luau .lute/build.luau .lute/test.luau .lute/lint.luau .lute/analyze.luau .lute/check.luau
grep -n -E "build-only|run-only" .lute/test.luau
grep -n ROBLOX_API_KEY .env.template
git grep -n FIXME -- workspace/flipbook-core/src/createFlipbookApp.luau
```
