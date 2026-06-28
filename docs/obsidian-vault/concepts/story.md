---
aliases: [Story]
linter-yaml-title-alias: Story
---

# Story

A Story renders a piece of UI on its own, in a sandboxed canvas. It's lifted out of your game so you can build and review it without running the whole experience to reach the screen it lives on.

Concretely, a Story is a [ModuleScript](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) with a `.story` extension that returns a table with a `story` function. Flipbook calls that function to mount the UI into the canvas, then tears it down when you navigate away:

```code-sample
workspace/code-samples/src/Default/Button.story.luau
```

This Story uses Flipbook's built-in function-based renderer: it builds a `TextButton` and returns it. Because you hand back the Instance, Flipbook owns its lifecycle and cleans it up so you don't leak instances while iterating.

When you need to manage the UI lifecycle yourself (for example, to parent instances to a specific location or to clean up connections on unmount), the `story` function can instead parent the UI to `props.container` and return a cleanup callback:

```code-sample
workspace/code-samples/src/Default/ButtonWithCleanup.story.luau
```

The legacy [[usage/migration-guides/migrating-hoarcekat|Hoarcekat]] shape, where the whole module is a `function(container)` that returns its own cleanup, is supported too. To render with a UI library instead, the same `story` function can return a React, Fusion, or Roact element; see [[usage/writing-stories|Writing Stories]] for wiring one up.

## The Canvas

Each Story renders into its own sandboxed canvas, isolated from the rest of your game. In a running experience a given piece of UI might only surface after a particular sequence of states (a panel that appears once its data has loaded, say), and reproducing that by hand on every edit is slow. The canvas lets you render that state directly and interact with it in place.

The canvas is closer to a Figma and Storybook hybrid than to a single fixed component. Today it renders a single Story, but it's built to grow toward multi-story views and documentation living alongside the live preview.

When you open a Story, Flipbook:

1. Loads the module fresh through [[concepts/module-loader|ModuleLoader]], bypassing Roblox's `require` cache so that editing the Story hot-reloads its preview without restarting the plugin.
2. Calls the `story` function with a [[api/story-props|StoryProps]] object: the render container, the current [[usage/controls|controls]], the Studio theme, and more.
3. Renders whatever the function returns into the canvas, and tears it down when you navigate away.

That fresh-load step is the reason saving a Story updates its preview instantly.

## Stories Without a Storybook

A Story doesn't strictly need a [[concepts/storybook|Storybook]] to be viewable. A Storybook declares `storyRoots` and tells Flipbook where to look, but a well-formed Story that no Storybook covers still appears. Flipbook surfaces orphaned Stories under an "Unavailable Stories" folder in the tree.

The harder hurdle is getting the module _shape_ right. Storyteller validates the returned table when it loads a Story and raises a "Story is malformed" error if it doesn't match, but there's no static typechecking to catch a missing `story` function or a misplaced field as you write, so a mistake tends to surface only when you open the Story. [[usage/typechecking|Typechecking]] with Storyteller's types is how you get ahead of it.

> [!seealso]
> [[api/story-format|Story Format]]: the full module API
> [[concepts/storybook|Storybook]] · [[usage/writing-stories|Writing Stories]]
