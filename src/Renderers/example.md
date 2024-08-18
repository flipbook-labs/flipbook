Plain GuiObjects

```lua
exports.Primary = {
    args = {
        isEnabled = true,
    },
    renderer = RobloxRenderer,
    render = function(args)
        local label = Instance.new("TextLabel")
        label.Text = if args.isEnabled then "Enabled" else "Disabled"

        return label
    end
}
```

Fusion

```lua
local function Button(props)
    local isHovering = Value(false)

    return New "TextButton" {
        BackgroundColor3 = Computed(function()
            return if isHovering:get() then HOVER_COLOUR else REST_COLOUR
        end),

        [OnEvent "MouseEnter"] = function()
            isHovering:set(true)
        end,

        [OnEvent "MouseLeave"] = function()
            isHovering:set(false)
        end,

        -- ... some properties ...
    }
end

local exports = {}
exports.Primary = {
    args = {
        isEnabled = true,
    },
    renderer = createFusionRenderer(Fusion),
    render = function(args)
        return New "TextLabel" {
            Text = Computed(function()
                return if args.isEnabled:get() then "Enabled" else "Disabled"
            end)
        }
    end
}
```


React

```lua
exports.Primary = {
    args = {
        isEnabled = true,
    }
    renderer = createReactRenderer(React, ReactRoblox),
    render = function(args)
        return React.createElement("TextLabel", {
            Text = if args.isEnabled then "Enabled" else "Disabled"
        })
    end
}
```
