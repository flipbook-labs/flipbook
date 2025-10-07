---
sidebar_position: 20
---

# Additional Notes

## Thinking in alpha values

`roact-spring` supports animating many different data types. However, sometimes it may be more convenient to animate from 0 to 1 and subscribe elements to it so they can interpolate between different values themselves. This is especially helpful when you want to subscribe multiple elements with different values to a single spring.

This is also helpful to ensure different elements that you want to animate together will truly stay together. You don't run the risk of animating some elements but forgetting to animate others.

One downside to this approach is that it's only convenient when elements are animating along a line between only 2 points. If you want to animate among arbitrary positions, using the relevant data type directly is more appropriate.

### Using different springs for each element
```lua
local function Example(_)
    local styles, api = RoactSpring.useSpring(function()
        return {
            position1 = UDim2.fromScale(0.2, 0.2),
            position2 = UDim2.fromScale(0.1, 0.8),
            position3 = UDim2.fromScale(0.6, 0.4),
        }
    end)

    React.useEffect(function()
        -- We need to call `api.start` for each value
        api.start({ position1 = UDim2.fromScale(0.8, 0.2) })
        api.start({ position2 = UDim2.fromScale(0.2, 0.6) })
        api.start({ position3 = UDim2.fromScale(0.5, 0.9) })
    end, {})

	return React.createElement(React.Fragment, nil, {
        Frame1 = React.createElement("Frame", {
            Position = styles.position1,
        }),
        Frame2 = React.createElement("Frame", {
            Position = styles.position2,
        }),
        Frame3 = React.createElement("Frame", {
            Position = styles.position3,
        }),
    })
end
```

### Using alpha values
```lua
local function Example(_)
    local styles, api = RoactSpring.useSpring(function()
        return {
            alpha = 0,
        }
    end)

    React.useEffect(function()
        -- We only have to call `api.start` once
        api.start({ alpha = 1 })
    end, {})

	return React.createElement(React.Fragment, nil, {
        Frame1 = React.createElement("Frame", {
            Position = styles.position:map(function(alpha)
                return UDim2.fromScale(0.2, 0.2):Lerp(UDim2.fromScale(0.8, 0.2), alpha)
            end),
        }),
        Frame2 = React.createElement("Frame", {
            Position = styles.position:map(function(alpha)
                return UDim2.fromScale(0.1, 0.8):Lerp(UDim2.fromScale(0.2, 0.6), alpha)
            end),
        }),
        Frame3 = React.createElement("Frame", {
            Position = styles.position:map(function(alpha)
                return UDim2.fromScale(0.6, 0.4):Lerp(UDim2.fromScale(0.5, 0.9), alpha)
            end),
        }),
    })
end
```
