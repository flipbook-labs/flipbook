---
aliases: [Storyteller API]
linter-yaml-title-alias: Storyteller API
notion-id: 12e95b79-12f8-80d6-920e-f3b38d960d37
base: "[[proposals.base]]"
Author:
  - Marin Minnerly
Tags: []
Status: In progress
Created: 2024-10-29T11:25:00
Approval: Drafting
---
# Storyteller API

[Storyteller](https://github.com/flipbook-labs/storyteller) is a library for the discovery and rendering of UI stories and is the backbone of flipbook’s Story discovery and rendering.

## Storybook Format

![[storybook-format]]

## Story Format

![[api/story-format]]

## API

### Types

#### Storybook

Represents a Storybook loaded from a ModuleScript

```lua
-- TODO: Paste type export
```

#### Story

Represents a Story loaded from a ModuleScript

```lua
-- TODO: Paste type export
```

#### StoryProps

### Functions

#### isStorybookModule

`isStorybookModule(instance: Instance): boolean`

| Tags | Validation, Storybook |
| --- | --- |

Validates a given Instance is a Storybook module.

#### isStoryModule

`isStoryModule(instance: Instance): boolean`

| Tags | Validation, Story |
| --- | --- |

Validates a given Instance is a Story.

No validation is performed on the internals of the module. Only name and class are checked.

See `loadStory` for validation of the module source.

#### findStorybookModules

`findStorybookModules(parent: Instance): { ModuleScript }`

| Tags | Discovery, Storybook |
| --- | --- |

Discovers all Storybook modules that are descendants of `parent`.

This is the first step in the discovery of Stories. Once you load a Storybook, you can then use its `storyRoots` array to discover all the Stories it manages.

#### findStoryModulesForStorybook

`findStoryModulesForStorybook(storybook: Storybook): { ModuleScript }`

| Tags | Discovery, Storybook, Story |
| --- | --- |

Discovers all Story modules that are managed by the given Storybook.

#### loadStorybookModule

`loadStorybookModule(loader: ModuleLoader, storybookModule: ModuleScript): Storybook`

| Tags | ModuleLoading, Storybook |
| --- | --- |

Loads the source of a Storybook module.

A [ModuleLoader](https://github.com/flipbook-labs/module-loader) instance is required for handling the requiring of the module.

This function will throw if the return value of `storybookModule` does not conform to [[proposals/storyteller-api|Storyteller API]], or if the source has a syntax error that `require` would normally fail for.

#### loadStoryModule

`loadStoryModule(loader: ModuleLoader, storyModule: ModuleScript, storybook: Storybook): Story`

| Tags | ModuleLoading, Story |
| --- | --- |

Loads the source of a Story module.

This function will throw if the return value of `storyModule` does not conform to [[proposals/storyteller-api|Storyteller API]], or if the source has a syntax error that `require` would normally fail for.

For legacy compatibility this function also loads Hoarcekat stories. Instead of a usual table-based Story definition, it takes the returned function and wraps it in a Story, making the `story` field the function body.

#### createRendererForStory

`createRendererForStory(story: Story): StoryRenderer`

| Tags | Rendering |
| --- | --- |

This function will do its best to determine which of the renderers to use based off the Story’s properties.

Each renderer is given its own file so that it’s easy to add on new UI libraries in the future. See [[proposals/story-renderer-spec|Story Renderer Spec]]  for more details.

> [!tip] 💡
> This likely won’t make it into the public API.  Aside from supplying packages, the consumer shouldn’t need to care about which renderer is being used. And we also make no effort to expose the individual renderers (as of right now) so for v1 we can omit this function and instead have `render` take `(story, container)` as args

#### Render

`render(renderer: StoryRenderer, container: Instance, story: Story<T>): RenderLifecycle`

| Tags | ModuleLoading, Story |
| --- | --- |

The final step. Once you have your Storybook, a Story to render, and the renderer to use for the Story, this function will handle the lifecycle of mounting, updating, and unmounting the Story for viewing.

Usage:

```lua
local ModuleLoader = require("@pkg/ModuleLoader")
local Storyteller = require("@pkg/Storyteller")

local loader = ModuleLoader.new()

local storybookModules = Storyteller.findStorybookModules(game)
assert(#storybookModules > 0, "no Storybook modules found")

local storybook
pcall(function()
  storybook = Storyteller.loadStorybookModule(loader, storybookModules[1])
end)

if storybook then
  local storyModules = Storyteller.findStoryModulesForStorybook(storybook)
  assert(#storyModules > 0, "no Story modules found")

  local story
  pcall(function()
	  story = Storyteller.loadStoryModule(loader, storyModules[1], storybook)
  end)
  
  if story then
	  local renderer = Storyteller.createRendererForStory(story)
	  local lifecycle = Storyteller.render(renderer, container, story)
	  
	  print(container:GetChildren())
	  
		lifecycle.unmount()
		
	  print(container:GetChildren())
  end
end
```

> [!tip] 💡
> We may update this function to make `renderer` an optional last argument in the future so that `createRendererForStory` can be called implicitly. Determining which renderer to use probably doesn’t need to be the consumer’s job.

### Hooks

Storyteller is intended for use by flipbook, so we also expose some React hooks to make it easier to handle the discovery and loading of Storybooks and Stories from React UI.

#### useStorybooks

`uesStorybooks(parent: Instance, loader: ModuleLoader): { Storybook }`

| Tags | React, Storybook |
| --- | --- |

Performs all the discovery and loading of Storybook modules that would normally be done via individual API members.

This hook makes it possible to conveniently load (and reload) Storybooks for use in React UI.

Usage:

```lua
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

local function StorybookList(props: { 
	parent: Instance, 
	loader: ModuleLoader,
})
	local storybooks = Storyteller.useStorybooks(props.parent, props.loader)
	
	local children = {}
	for index, storybook in storybooks do
		children[storybook.name] = e("TextLabel", {
			Text = storybook.name,
			LayoutOrder = index,
		}),
	end
	
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
	}, children)
end

return StorybookList
```

This hook triggers a rerender when a Storybook module changes. For example, updating the `storyRoots` of a Storybook will trigger a rerender, and when paired with `useStory` you can get live updates to which Stories a Storybook manages.

> [!tip] 💡
> In the future version hooks may be migrated to a new package to remove the React dependency from Storyteller.

#### useStory

`uesStory(storyModule: ModuleScript, storybook: Storybook, loader: ModuleLoader): Story `

| Tags | React, Story |
| --- | --- |

This hook triggers a rerender when the Story module or any of its required modules change. For example, updating the `story` property or updating a React component’s source will trigger useStory to rerender with the new content.

Usage:

```lua
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local useEffect = React.useEffect
local useRef = React.useRef
local e = React.createElement

local function StoryView(props: {
	parent: Instance,
	storyModule: ModuleScript,
	storybook: Storybook,
	loader: ModuleLoader,
})
	local ref = useRef(nil :: Frame?)

	local story = Storyteller.useStory(props.storyModule, props.storybook, props.loader)

	useEffect(function()
		if ref.current then
			local renderer = Storyteller.createRendererForStory(story)
			Storyteller.render(renderer, ref.current, story)
		end
	end, { story })

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ref = ref,
	})
end

return StoryView

```

> [!tip] 💡
> In the future version hooks may be migrated to a new package to remove the React dependency from Storyteller.

## References

* [[proposals/create-flipbook-package|Create a flipbook package]]
