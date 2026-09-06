# Multi-story integration scenario

Use this scenario to prove that Flipbook can discover, select, render, and control more than one concrete Story exported by the same module. Follow the connection, discovery, readiness, and visual-check workflow in the parent [`use-studio-mcp-for-flipbook`](../SKILL.md) skill.

## Fixture

- Storybook name: `Agent Multi-Story E2E`
- Story module suffix: `MultipleStories.story`
- Concrete Stories: `Primary` with id `primary`, and `Secondary` with id `secondary`
- Expected control: `label`
- Expected previews: blue for Primary and purple for Secondary

The Storybook omits FlipbookCore's `mapStory` provider wrapper so the scenario isolates concrete Story selection and rendering from FlipbookCore's nested Storybook context.

## Semantic proof

1. Call `listStorybooks` and select the result named `Agent Multi-Story E2E`. A built Storybook place can expose both runtime and plugin-debug copies; when more than one result has that name, select the returned path rooted at `ReplicatedStorage.FlipbookWorkspace`.
2. Call `listStories` with that result's path. Select the two results whose module path ends in `MultipleStories.story`; use the returned paths and ids in later calls.
3. For each concrete Story, call `openStory` with the returned module path, Storybook path, and id.
4. Poll `getCurrentStory` until its id matches the requested id and `isMounted` is true. Poll `getControls` until the `label` control exists.
5. Set a distinct label with `setControls`, then confirm the value through `getControls`.

Record the discovered paths and returned ids as evidence. The scenario must not depend on a hard-coded DataModel path.

## Visual proof

After both concrete Stories pass semantic verification, turn viewport preview off, leave each Story open in turn, and inspect the native Studio window. Confirm that Primary shows the blue preview and its distinct label, then that Secondary shows the purple preview and its distinct label.

If native Studio-window inspection is unavailable, use the parent skill's embedded visual workflow. Treat client errors or a failure to mount the embedded UI as a visual-check failure, and stop play mode when finished.

The semantic results remain authoritative for concrete Story selection because a screenshot cannot prove which Story id is active.
