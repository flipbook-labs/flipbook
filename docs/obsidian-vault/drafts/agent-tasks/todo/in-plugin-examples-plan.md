# Plan — in-plugin worked examples (onboarding)

> [!note]
> Standalone plan for a future session. Build-excluded (`drafts/`). Split out of the docs learning-effectiveness effort (`~/.claude/plans/tidy-mapping-lemur.md`, "Track B") so it can be tackled on its own. This one spans the **plugin codebase**, not just docs. Status: **not started**.

## Why

The learning-effectiveness report (`drafts/storybook-docs-comparison-learning.md`) found that Storybook's single strongest teaching advantage is **manipulable worked examples** in onboarding: a new user opens a running artifact and tweaks it, rather than authoring from a blank page. Flipbook's current onboarding is "hand-write a Storybook and a Story, then place them in ReplicatedStorage" before anything renders. Shipping example Stories the user can open and edit on first run is the highest-impact onboarding change, and it's a product change the docs can't substitute for.

## Goal

When a user opens Flipbook for the first time (or has no Storybooks of their own), surface a set of ready-made example Stories they can open, interact with, and edit, so the first thing they see is a working component and live controls rather than an empty tree.

## The example to build

From the maintainer's own steer: a small **to-do list** Story that shows off interaction and controls:

- A `numItems` control to set how many items render (cap at 10).
- A control for completed-item styling (e.g. strike-through vs. fade-out).
- Ideally **stateful** so the user can check items off in the preview and see it respond.

> [!warning]
> The stateful version has a product dependency: today, changing a control re-renders the Story and **loses component state**. A genuinely interactive to-do example wants control changes to preserve state. The maintainer flagged this as a fix worth doing alongside (or before) this work. Treat "controls don't reset state" as a prerequisite for the interactive version; a non-stateful version can ship without it.

## Design decisions to resolve

1. **Delivery model.** Bundle the examples inside the plugin so they're always present, vs. a one-click "insert examples into my place" action, vs. surfacing them only as an empty state when the user has no Storybooks. Trade-off is discoverability vs. clutter once the user has their own stories.
2. **Source of the examples.** Reuse `workspace/code-samples` as the single source so docs and in-plugin examples can't drift apart, vs. a purpose-built demo set tuned for the first-run experience. Prefer reuse unless the onboarding example needs to be richer than the docs samples (the to-do list likely is).
3. **First-run surfacing.** An empty-state call-to-action when no Storybooks are found, and/or a light first-open tour or callouts pointing at the canvas and the controls panel.

## Surfaces it spans

- **Plugin UI** (`src/`): the empty state and/or an "Examples" entry in the Storybook tree.
- **Build**: bundling the demo Stories into the published `Flipbook.rbxm` so they ship with the plugin.
- **First-open affordance**: detecting first run / no-Storybooks and showing the examples.

## Out of scope

- The docs-side Track A work (done separately).
- Any change to the public Story/Storybook format.

## Open questions

- Bundle-always vs. insert-on-demand vs. empty-state-only (decision 1)?
- Do we gate the interactive to-do example on the control-state-preservation fix, or ship a non-stateful version first?
- Should the examples cover every framework (React/Fusion/Roact + vanilla), or one representative vanilla/React example to start?

## Pointers

- Rationale: `drafts/storybook-docs-comparison-learning.md`.
- `code-samples` conventions and the existing example Stories: `workspace/code-samples/src/`.
- The shipped Story/Storybook/controls APIs are documented under `usage/` and `api/`.
