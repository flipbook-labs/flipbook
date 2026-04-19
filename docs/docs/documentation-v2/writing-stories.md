---
notion-id: 12f95b79-12f8-80f8-bc67-d572562ef114
aliases: [Writing Stories]
linter-yaml-title-alias: Writing Stories
---

# Writing Stories

| Upstream | [https://flipbook-labs.github.io/flipbook/docs/writing-stories](https://flipbook-labs.github.io/flipbook/docs/writing-stories) |
| --- | --- |

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

TODO: Define how manual stories work. We may need to introduce a breaking change to the function signature.

```markdown
Manual story

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

No return value. Renderer will implicitly call ClearAllChildren on the container, but no other efforts will be made to cleanup side-effects of the story

```lua
return {
    story = function(props)
        local gui = Instance.new("TextLabel")
    end
}
```

UI Labs and Hoarcekat

```lua
return function(target, props)
    local gui = Instance.new("TextLabel")
    gui.Parent = target

    return function()
        gui:Destroy()    
    end
end
```

```

# Controls

TODO TODO TODO

# Type Checking

See [[Story and Storybook typechecking]] 

# SurfaceGui and BillboardGui

[https://github.com/flipbook-labs/flipbook/issues/230](https://github.com/flipbook-labs/flipbook/issues/230)
