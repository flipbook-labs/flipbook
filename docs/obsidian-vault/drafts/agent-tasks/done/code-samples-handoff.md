# Code-samples bolstering — completion record

> [!note]
> **Status: done.** New example Stories were added to `workspace/code-samples` to demonstrate authoring shapes the docs previously never showed, lifting the _patterns_ (not verbatim code) from Storyteller's e2e suite. Kept as a record. Lives in `drafts/` (build-excluded). Part of the docs learning-effectiveness effort (plan: `~/.claude/plans/tidy-mapping-lemur.md`).

## What landed

- **Hoarcekat set** (`src/Hoarcekat/`) — `HelloWorldLabelBefore.story.luau` (the legacy bare-`function(target)`-returns-cleanup shape), the migrated `HelloWorldLabel.story.luau`, the `HelloWorldLabel` component, and `Hoarcekat.storybook.luau`. Backs the `usage/migration-guides/migrating-hoarcekat.md` rebuild.
- **Manual cleanup** (`src/Default/ButtonWithCleanup.story.luau`) — `story = function(props)` parents into `props.container` and returns a teardown callback. Backs the "manage the lifecycle yourself" beat in `concepts/story.md`.
- **Controls on a plain Instance** (`src/Default/ButtonWithControls.story.luau`) — shows the `controls` / `props.controls` pattern works with the function-based renderer, not just React. Backs `usage/controls.md`.

## Dropped

- **Component-as-story / element-as-story** — at the maintainer's request these forms are _not_ encouraged, so the samples (`ReactComponentAsStory`, `ReactElementAsStory`, and their `ReactLabel` component) and the docs section referencing them were removed. Do not re-add.

## Verified source facts (kept for reference)

From Storyteller `main` (`src/renderers/createManualRenderer.luau` + `src/loadStoryModule.luau`), the function-based ("manual") renderer accepts:

- `story` is an **Instance** → Flipbook parents and manages it.
- `story` is a **function** → called with `(props)`, or `(container, props)` if it declares ≥2 params (`debug.info(fn, "a") >= 2`). If it returns an Instance, Flipbook parents it; if it returns a function, that's a **cleanup** callback run on unmount.
- **Hoarcekat legacy shape**: when the whole module returns a function, `loadStoryModule` wraps it as `story = function(props) return callback(props.container, props) end`, so a bare `function(target)` receives the container.

## Conventions (for future sample work)

- Edit `src/` only — `build/` is generated. Aliases (`.luaurc`): `@pkg`, `@rbxpkg`, `@root`; local modules via relative requires. Strict `languageMode`.
- One PascalCase folder per framework/topic; `X.story.luau`, component `X.luau`, storybook `X.storybook.luau`.
- Build/verify from repo root: `lute run install`, `lute run build`, `lute run analyze`.
- Wire each sample into docs with a ` ```code-sample ` block whose body is the `workspace/code-samples/src/...` path — never paste code inline.
