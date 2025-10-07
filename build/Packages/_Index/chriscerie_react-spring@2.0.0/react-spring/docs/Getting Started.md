---
sidebar_position: 2
---

# Getting Started

## Getting started with function components and hooks

Getting started with roact-spring is easy. For function components with hooks, the basic spring is [useSpring](/docs/hooks/useSpring), but the same concept applies to all animation primitives. Let's have a look...

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

-- When button is pressed, animate transparency to 0
local function App(_)
    local styles, api = RoactSpring.useSpring(function()
        return { transparency = 1 }
    end)

    return React.CreateElement("TextButton", {
        Size = UDim2.fromScale(0.5, 0.5),
        Transparency = styles.transparency,
        [React.Event.Activated] = function()
            api.start({ transparency = 0 })
        end,
    })
end
```

`roact-spring` supports both [Roact17](https://github.com/grilme99/CorePackages) and [legacy Roact](https://github.com/Roblox/roact) with [roact-hooks](https://github.com/Kampfkarren/roact-hooks). Usage with legacy Roact and roact-hooks requires you to pass the `hooks` table to roact-spring's hooks.

#### Using Roact17:
```lua
local function App(_)
    local styles, api = RoactSpring.useSpring(function()
        return { transparency = 1 }
    end)
end
```

#### Using legacy Roact with roact-hooks:
```lua
local function App(_, hooks)
    local styles, api = RoactSpring.useSpring(hooks, function()
        return { transparency = 1 }
    end)
end
```

The rest of this documentation's examples will assume we are using Roact17.

## Getting started with class components

For class components, the basic spring is [Controller](/docs/Additional%20Classes/controller). Let's have a look...

:::note
Function components with hooks are always preferred over class components. For more information, see React's [motivation for hooks](https://reactjs.org/docs/hooks-intro.html#motivation).
:::note

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

function App:init()
    self.styles, self.api = RoactSpring.Controller.new({
        transparency = 1 
    })
end

-- When button is pressed, animate transparency to 0
function App:render()
    return React.CreateElement("TextButton", {
        Size = UDim2.fromScale(0.5, 0.5),
        Transparency = self.styles.transparency,
        [React.Event.Activated] = function()
            self.api:start({ transparency = 0 })
        end,
    })
end
```

## Up-front interpolation

Springs don't just handle numbers! They take the following types:

* Number
* Color3
* Vector2
* Vector3
* UDim
* UDim2

## Next steps

If you are using hooks, read [useSpring](/docs/hooks/useSpring) as well as [props](/docs/common/props) and [configs](/docs/common/configs). After, read through the other provided hooks for more advanced animations.

If you are using class components, read [Controller](/docs/Additional%20Classes/controller) as well as [props](/docs/common/props) and [configs](/docs/common/configs).