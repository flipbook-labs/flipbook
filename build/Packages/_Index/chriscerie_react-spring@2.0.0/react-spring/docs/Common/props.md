---
sidebar_position: 2
---

# Props

## Overview

```lua
RoactSpring.useSpring({
    from = { ... }
})
```

All primitives inherit the following properties (though some of them may bring their own additionally):

| Property | Type | Description  |
| ----------- | ----------- | ---- |
| from | table | Starting values |
| to | table | Animates to ... |
| loop | table/fn/bool | Looping settings, see [loop prop](props#loop-prop) for more details |
| delay | number | Delay in seconds before the animation starts |
| immediate | boolean | Prevents animation if true |
| [config](configs) | table | Spring config (contains mass, tension, friction, etc) |
| reset | bool | The spring starts to animate from scratch (from -> to) if set true |
| default | bool | Sets default value of compatible props if true. See [default props](props#default-props) for more details |

## Advanced Props

### Loop prop

Use `loop = true` to repeat an animation.

```lua
-- Transparency repeatedly animates from 0 to 1
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    to = { transparency = 1 },
    loop = true,
})
```

### The `loop` function

Pass a function to be called after each loop. Return `true` to continue looping, or `false` to stop.

```lua
-- Transparency animates from 0 to 1 three times
local count = React.useRef(0)
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    to = { transparency = 1 },
    loop = function()
        count += 1
        return 3 > count.value
    end,
})
```

### The `loop` table

Define a `loop` table to customize the loop animation separately from the initial animation. It may contain any of the `useSpring` props. For example, if delay: 1 is used, the loop animation will delay for 1 second on each loop.

```lua
-- Transparency repeatedly animates from 0 to 1 with 1 second delays
local count = React.useRef(0)
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    to = { transparency = 1 },
    loop = { delay = 1, reset = true },
})
```

#### Inherited props

The `loop` object is always merged into a copy of the props object it was defined in. The following example shows a loop animation that inherits its config prop.

```lua
-- The loop doesn't run more than once
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    loop = { transparency = 1 },
})
```

⚠️ The loop doesn't run more than once. That's because some props are never inherited. These props include default, reset, and reverse

**To loop the animation,** try adding `reset = true` to the loop prop in the above example. Alternatively, you could add `from = { transparency: 1 }` to get the same effect.

Lastly, try adding `config = { friction: 5 }` to the loop object. This overrides the inherited config with a springy animation.

```lua
-- Transparency repeatedly animates from 0 to 1
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    loop = {
        transparency = 1,
        reset = true,
    },
})

-- Transparency repeatedly animates from 0 to 1
local styles = RoactSpring.useSpring({
    from = { transparency = 0 },
    loop = {
        transparency = 1,
        from = { transparency = 1 },
    },
})
```

### Reset prop

Use the `reset` prop to start the animation from scratch. When undefined in imperative updates, the spring will assume `reset` is true if `from` is passed. 

```lua
local styles, api = RoactSpring.useSpring(function()
    return { transparency = 0.5 }
end)

-- The spring will start from 0
api.start({
    from = { transparency = 0 },
    to = { transparency = 1 },
})

-- The spring will ignore `from` and start from its current position
api.start({
    reset = false,
    from = { transparency = 0 },
    to = { transparency = 1 },
})
```

In declarative updates, the spring will assume reset is false if reset is not passed in.

```lua
-- The spring will start from 0.2 on mount and ignore `from` on future updates
local styles = RoactSpring.useSpring({
    from = { transparency = 0.2 },
    to = { transparency = if toggle then 0 else 1 },
}, { toggle })

-- The spring will always start from scratch from 0.2
local styles = RoactSpring.useSpring({
    reset = true,
    from = { transparency = 0.2 },
    to = { transparency = if toggle then 0 else 1 },
}, { toggle })
```

## Default Props

The default prop lets you set the default value of certain props defined in the same update.

### Declarative updates

For the declarative API, this prop is `true` by default.

### Imperative updates

Imperative updates can use `default: true` to set default props.

```lua
local styles, api = RoactSpring.useSpring(function()
    return {
        position = UDim2.fromScale(0.5, 0.5),
        config = { tension = 100 },
        default = true,
    }
end)

React.useEffect(function()
    -- The `config` prop is inherited by the animation
    -- Spring will animate with tension at 100
    api.start({ position = UDim2.fromScale(0.3, 0.3) })
end)
```

### Compatible props

The following props can have default values:

* `config`
* `immediate`
