---
sidebar_position: 4
---

# Imperatives

## Imperative API

Passing a function to `useSpring` or `useSprings` will return an imperative API table. The following shows the difference between using the imperative and declarative API for toggling transparency.

```lua
--[[
    Using declarative API
]]
local toggle, setToggle = useState(false)
local styles = RoactSpring.useSpring({
    transparency = if toggle then 0 else 1,
})

-- Later
setToggle(function(prevState)
    return not prevState
end)


--[[
    Using imperative API
]]
local styles, api = RoactSpring.useSpring(function()
    return { transparency = 1 }
end)

-- Later
api.start({ transparency = if styles.transparency:getValue() == 1 then 0 else 1 })
```

The rest of this page will use the imperative API.

You can also specify configs for each animation update.

```lua
api.start({
    position = UDim2.fromScale(0.5, 0.5),
    rotation = 0,
    config = { mass = 10, tension = 100, friction = 50 },
})
```

To run tasks after an animation has finished, chain the returned promise with `andThen`.

```lua
api.start({
    position = UDim2.fromScale(0.5, 0.5),
    rotation = 0,
}):andThen(function()
    print("Animation finished!")
end)
```

## API methods

The api table in the second value returned from a spring has the following functions:

```lua
local api = {
    -- Start your animation optionally giving new props to merge 
    start: (props) => Promise,
    -- Cancel some or all animations depending on the keys passed, no keys will cancel all.
    stop: (keys) => void,
    -- Pause some or all animations depending on the keys passed, no keys will pause all.
    pause: (keys) => void,
}
```

:::note
roact-spring guarantees that the api table identity is stable and won’t change on re-renders. This is why it’s safe to omit from the useEffect or useCallback dependency array.
:::note
