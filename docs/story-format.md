---
sidebar_position: 3
---

# Story Format

Stories can be written in several different formats to accomodate different workflows. This document outlines those formats with examples of how to use them.

## Storybook

Storybooks are your entypoint to flipbook and you'll need at least one to start using it.

The only required prop is the `storyRoots` array, which tells flipbook which Instances to search the descendants of for `.story` files

| Name          | Type           | Notes                                                                                             |
| ------------- | -------------- | ------------------------------------------------------------------------------------------------- |
| `storyRoots`  | `{ Instance }` | An array of instances to search the descendants of for `.story` files.                            |
| `name`        | `string?`      | The name to use for the storybook. This defaults to `script.Name` with `.storybook` stripped off. |
| `roact`       | `Roact?`       | The version of Roact to use across all stories.                                                   |
| `react`       | `React?`       | The version of React to use across all stories.                                                   |
| `reactRoblox` | `ReactRoblox?` | The version of ReactRoblox to use when mounting React components.                                 |

Example:

```lua
-- example/Example.storybook.luau
return {
	name = "Example Storybook",
	storyRoots = {
		script.Parent,
	},
}
```

## Roact Story

Support for Roblox's [Roact](https://github.com/Roblox/roact) library is built in to flipbook, allowing you to supply your copy of Roact and return Roact elements to create stories.

| Name     | Type                                                      | Description                                                                                                                                                                                             |
| -------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| story    | `RoactElement    \| (props: StoryPropss) -> RoactElement` | Your story can either be a Roact element or a function that accepts props and returns a Roact element. The latter format is needed to support the use of controls. See below for an example             |
| roact    | `Roact`                                                   | This must be set to your copy of Roact. Since Roact uses special symbols for things like children, flipbook needs to mount the story with the same copy of Roact that you used to create your elements. |
| name     | `string?`                                                 | Optional name for the story. Defaults to the file name.                                                                                                                                                 |
| summary  | `string?`                                                 | Optional description of the story that will appear as part of the information at the top of the preview.                                                                                                |
| controls | `StoryControls?`                                          | Optional controls to see how your story behaves with various props.                                                                                                                                     |

Example:

```lua
-- example/Button.story.luau
local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "A generic button component that can be used anywhere",
	roact = Roact,
	story = Roact.createElement(Button, {
		text = "Click me",
		onActivated = function()
			print("click")
		end,
	}),
}
```

Example with controls:

```lua
-- example/ButtonWithControls.story.luau
local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local ButtonWithControls = require(script.Parent.ButtonWithControls)

local controls = {
	isDisabled = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	roact = Roact,
	story = function(props: Props)
		return Roact.createElement(ButtonWithControls, {
			text = "Click me",
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}
```

## React Story

Roblox's unreleased React 17 port is natively supported by flipbook, allowing you to use the React and ReactRoblox packages for mounting your components.

You can find React and ReactRoblox as part of the [CorePackages](https://github.com/grilme99/CorePackages) repo on GitHub.

| Name        | Type                                                      | Description                                                                                                                                                                                             |
| ----------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| story       | `ReactElement    \| (props: StoryPropss) -> ReactElement` | Your story can either be a React element or a function that accepts props and returns a React element. The latter format is needed to support the use of controls. See below for an example             |
| react       | `React`                                                   | This must be set to your copy of React. Since React uses special symbols for things like children, flipbook needs to mount the story with the same copy of React that you used to create your elements. |
| reactRoblox | `ReactRoblox`                                             | This must be set to your copy of ReactRoblox that is compatible with the supplied copy of React. This is used by flipbook to mount your React components.                                               |
| name        | `string?`                                                 | Optional name for the story. Defaults to the file name.                                                                                                                                                 |
| summary     | `string?`                                                 | Optional description of the story that will appear as part of the information at the top of the preview.                                                                                                |
| controls    | `StoryControls?`                                          | Optional controls to see how your story behaves with various props.                                                                                                                                     |

Example:

```lua
-- example/ReactCounter.story.luau
local Example = script:FindFirstAncestor("Example")

local React = require(Example.Parent.Packages.React)
local ReactRoblox = require(Example.Parent.Packages.ReactRoblox)
local ReactCounter = require(script.Parent.ReactCounter)

local controls = {
	increment = 1,
	waitTime = 1,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A simple counter that increments every second. This is a copy of the Counter component, but written with React",
	controls = controls,
	react = React,
	reactRoblox = ReactRoblox,
	story = function(props: Props)
		return React.createElement(ReactCounter, {
			increment = props.controls.increment,
			waitTime = props.controls.waitTime,
		})
	end,
}
```

## Functional Story

A Functional story uses a function to create and mount UI. This is the most flexible story format and is useful when using a UI library that is not yet natively supported by flipbook. You simply parent your UI elements to the `target` argument and optionally return a function that gets called to cleanup the story.

| Name     | Type                                                     | Description                                                                                                                                                                                                                                  |
| -------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| story    | `(parent: GuiObject, props: StoryProps) -> (() -> ()))?` | Like you might expect, a Functional story uses a function to create and mount the story. This is the most flexible story format and is useful when using a UI library that is not yet natively supported. You simply parent your UI elements |
| name     | `string?`                                                | Optional name for the story. Defaults to the file name.                                                                                                                                                                                      |
| summary  | `string?`                                                | Optional description of the story that will appear as part of the information at the top of the preview.                                                                                                                                     |
| controls | `StoryControls?`                                         | Optional controls to see how your story behaves with various props.                                                                                                                                                                          |

Example:

```lua
-- example/Functional.story.luau
local controls = {
	text = "Functional Story",
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "This story uses a function with a cleanup callback to create and mount the gui elements. This works similarly to Hoarcekat stories but also supports controls and other metadata. Check out the source to learn more",
	controls = controls,
	story = function(parent: GuiObject, props: Props)
		local label = Instance.new("TextLabel")
		label.Text = props.controls.text
		label.Font = Enum.Font.Gotham
		label.TextColor3 = Color3.fromRGB(0, 0, 0)
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 16
		label.AutomaticSize = Enum.AutomaticSize.XY

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 8)
		padding.PaddingRight = padding.PaddingTop
		padding.PaddingBottom = padding.PaddingTop
		padding.PaddingLeft = padding.PaddingTop
		padding.Parent = label

		label.Parent = parent

		return function()
			label:Destroy()
		end
	end,
}
```

## Hoarcekat Story

[Hoarcekat](https://github.com/Kampfkarren/hoarcekat) stories are supported to make migration to flipbook easier.

See the [migration guide](migrating.md) for more info.

Example:

```lua
-- example/Hoarcekat.story.luau
local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)

return function(target: Instance)
	local root = Roact.createElement("TextLabel", {
		Text = "Hoarcekat Story",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.fromOffset(300, 100),
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})

	local tree = Roact.mount(root, target)

	return function()
		Roact.unmount(tree)
	end
end
```
