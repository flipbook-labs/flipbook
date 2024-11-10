# Writing Stories

Before Storyteller can discover your Stories, you need a Storybook. This is the topmost configuration for each collection of Stories in your project.

Create a Storybook anywhere in the DataModel, and set the `storyRoots` array to point to an instance that contains your Stories:

```lua
return {
	storyRoots = {
		script.Parent.Components
	},
}
```

The `storyRoots` array is the only required property in a Storybook, and can manage many "roots," where a root  is simply an Instance that has Story modules nested inside it.

By default, Storyteller uses a function-based renderer with support for Roblox Instances to get you up and running. The following is all you need to be compatible with Storyteller:

```lua
return {
	story = function()
	  local label = Instance.new("TextLabel")
	  label.Text = "Hello, World!"

	  return label
	end
}
```

Storyteller also has built-in support for prominent UI libraries like React and Fusion. You can tell Storyteller to use a particular UI library by supplying the `packages` object.

```lua
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	story = React.createElement("TextLabel", {
		label.Text = "Hello, World!"
	}),
	packages = {
		React = React,
		ReactRoblox = ReactRoblox
	}
}
```

It can be tedious to supply the `packages` object in each Story module, which is why it’s more common to add them globally in the Storybook module so that all Stories can render with the UI library you use across your project.

```lua
local React = require("@pkg/React")

return {
	story = React.createElement("TextLabel", {
		label.Text = "Hello, World!"
	}),
}
```

```lua
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	storyRoots = { script.Parent.Components },
	packages = {
		React = React,
		ReactRoblox = ReactRoblox
	}
}
```

## Manual story

Return value is a function. `target` is not implicitly cleaned in this case
```lua
return {
    story = function(target, props)
        local gui = Instance.new("TextLabel")
        gui.Parent = target

        return function()
            gui:Destroy()
        end
    end
}
```

Return value is an Instance. Renderer will implicitly Parent the Instance to the container and call Destroy when unmounting

```lua
return {
    story = function(props)
        local gui = Instance.new("TextLabel")

        return gui
    end
}
```

No return value. Renderer will implicitly call `ClearAllChildren` on the container, but no other efforts will be made to cleanup side-effects of the story

```lua
return {
    story = function(props)
        local gui = Instance.new("TextLabel")
    end
}
```

## UI Labs and Hoarcekat

```lua
return function(target: Instance, props: { [string]: any })
    local gui = Instance.new("TextLabel")
    gui.Parent = target

    return function()
        gui:Destroy()
    end
end
```

## Controls

TODO TODO TODO

## Type Checking

See [Story and Storybook typechecking](https://www.notion.so/Story-and-Storybook-typechecking-12f95b7912f8809b9842f96897b55438?pvs=21)

## SurfaceGui and BillboardGui

https://github.com/flipbook-labs/flipbook/issues/230
