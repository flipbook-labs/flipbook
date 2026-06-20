---
aliases: [Story Renderer Spec]
linter-yaml-title-alias: Story Renderer Spec
notion-id: 4260feea-b457-4ad6-8f87-006dee57cf75
base: "[[proposals.base]]"
Author:
  - Marin Minnerly
Tags: []
Status: In progress
Created: 2024-04-24T07:31:00
Approval: Drafting
---

# Story Renderer Spec

The render API allows any UI library to be supported as the renderer for a flipbook story.

For each renderer, flipbook provides a mounting point, context, and lifecycle hooks to handle rendering, lifetime, and cleanup.

## Supported Renderers

| **Name** | **Format** |
| --- | --- |
| React | Result of React.createElement or a function that takes `props` as the first argument and creates an element |
| Roact | Result of Roact.createElement or a function that takes `props` as the first argument and creates an element |
| Fusion | Result of [`Fusion.New`](http://fusion.new/) or a function that takes `props` as the first argument and creates an Instance |
| Functional | A function that takes `props` as the first argument and returns an Instance |
| Manual (Legacy) | A function that takes `target` as the first argument, `props` as the second, and optionally returns a function for manually cleaning up  |
| Hoarcekat (Legacy) | Same as `Manual (Legacy)` but the story file itself is represented by a function |

Future:

* [Vide - A reactive UI library for Luau](https://centau.github.io/vide/)
* [Blend | Nevermore](https://quenty.github.io/NevermoreEngine/api/Blend/)
* Developer Storybook

## Implementing a Renderer

All renderers live here: [storyteller/src/renderers at main · flipbook-labs/storyteller](https://github.com/flipbook-labs/storyteller/tree/main/src/renderers).

When writing tests for a renderer, the `render` function must be used to ensure each renderer behaves properly with lifecycles.

When adding a new renderer, use the existing ones as reference and use the below API docs to hook up all necessary behavior for your UI library.

## API

### Props

#### Theme

`theme: "Dark" | "Light"`

The name of the current Roblox Studio theme.

#### Container

`container: Instance`

The location where GuiObjects will be rendered to.

#### Story

`story: Story`

Reference to the Story that is being rendered.

#### Storybook

`storybook: Storybook`

Reference to the Storybook that the Story is a part of.

#### Controls

`controls: { [string]: any }`

All the values provided by the story controls. The contents of this vary based on the story being rendered.

### Renderer

```lua
export type Renderer = {
	mount: (container: Instance, element: unknown, context: Context) -> GuiObject | Folder,
	update: ((controls: StoryControls<T>) -> ())?,
	
	transformArgs: ((args: Args, context: Context) -> Args)?,
	shouldUpdate: ((context: Context, prevContext: Context?) -> boolean)?,
	unmount: ((context: Context) -> ())?,
}
```

#### Mount

`mount(container: Instance, element: unknown, context: RenderContext)`

This function handles the initial mounting of a UI element to the container.

The first two arguments `container` and `element` are provided for convenience and are identical to `context.container` and `context.story.story`, respectively.

#### Update

`update(context: RenderContext, prevContext: RenderContext)`

Called any time something changes to RenderContext and determines if the story should re-render, and how.

This is a general purpose function for handling any context change. For example, by comparing `context` and `prevContext` a renderer can choose how it wants to re-render a story when controls change. In the case of Roact new GuiObjects are created, whereas Fusion relies on stable identities and instead relies on `transformContext` to

#### Unmount

`unmount()`

Called when a story is closed. This function handles cleanup for the `mount` function so there are no lingering UI elements between stories.

#### transformContext

> [!tip] 💡
> Can we get by with only one of update/transformContext? The lifecycle we need to support is…

1. Story opened. Initial mount
2. Something changes (controls, theme, containerType). Allow modifications to context as needed, and conditionally re-render
3. Story closed. Cleanup

`transformContext(context: RenderContext, prevContext: RenderContext?): RenderContext`

This function is always called before `mount` and `update` in order to transform the RenderContext object provided to them.

For the Fusion renderer, `context.controls` has each of its values mapped to `Fusion.Value`, and if `prevContext` is supplied then each Value has `:set()` called on it. This ensures the rendered GuiObjects maintain stable identities, while still updating from changes to controls.

## Usage

React

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return {
    storyRoots = {
        script.Parent.Components,
    },
    renderer = {
		    name = "React",
        react = React,
        reactRoblox = ReactRoblox,
    },
}
```

Fusion

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

return {
    storyRoots = {
        script.Parent.Components,
    },
    renderer = {
		    name = "Fusion",
        fusion = Fusion,
    },
}
```
