---
sidebar_position: 3
---

# Configs

## Overview

Springs are configurable and can be tuned. If you want to adjust these settings, you can provide a default `config` table to `useSpring`:

```lua
local styles, api = RoactSpring.useSpring(function()
    return {
        from = {
            position = UDim2.fromScale(0.5, 0.5),
            rotation = 0,
        },
        config = { mass = 10, tension = 100, friction = 50 },
    }
})
```

Configs can also be adjusted when animating the spring. If there isn't any config provided, the default config will be used.

```lua
api.start({
    position = UDim2.fromScale(0.5, 0.5),
    rotation = 0,
    config = { mass = 10, tension = 100, friction = 50 },
})
```

The following configs are available:

| Property | Default | Description  |
| ----------- | ----------- | ---- |
| mass | 1 | spring mass |
| tension | 170 | spring energetic load |
| friction | 26 | spring resistance |
| clamp | false | when true, stops the spring once it overshoots its boundaries |
| velocity | 0 | initial velocity, see [velocity config](/docs/common/configs#velocity-config) for more details |
| easing | t => t | linear by default, there is a multitude of easings available [here](/docs/common/configs#easings) |
| damping | 1 | The damping ratio, which dictates how the spring slows down. Only works when `frequency` is defined. Defaults to `1`. |
| progress | 0 | When used with `duration`, it decides how far into the easing function to start from. The duration itself is unaffected. |
| duration | undefined | if > than 0, will switch to a duration-based animation instead of spring physics, value should be indicated in seconds (e.g. duration: 2 for a duration of 2s) |
| frequency | undefined | The frequency response (in seconds), which dictates the duration of one period in a frictionless environment. When defined, `tension` is derived from this, and `friction` is derived from this and `damping`. |
| bounce | undefined | When above zero, the spring will bounce instead of overshooting when exceeding its goal value. |
| precision | undefined | How close to the end result the animated value gets before we consider it to be "there". When undefined, ideal precision will be calculated by the distance from `from` to `to` |
| restVelocity | undefined | The smallest velocity before the animation is considered to be "not moving". When undefined, precision is used instead. |

<iframe src="https://codesandbox.io/embed/react-spring-config-x1vjb?fontsize=14&hidenavigation=1&theme=dark&view=preview"
    width="100%"
    height="500"
    title="react-spring-config"
    allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
    sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
></iframe>

## Presets

There are also a couple of generic presets that will cover some common ground.

```lua
RoactSpring.config = {
    default = { mass: 1, tension: 170, friction: 26 },
    gentle = { mass: 1, tension: 120, friction: 14 },
    wobbly = { mass: 1, tension: 180, friction: 12 },
    stiff = { mass: 1, tension: 210, friction: 20 },
    slow = { mass: 1, tension: 280, friction: 60 },
    molasses = { mass: 1, tension: 280, friction: 120 },
}
```

<iframe src="https://codesandbox.io/embed/react-spring-preset-configs-kdv7r?fontsize=14&hidenavigation=1&theme=dark&view=preview"
    width="100%"
    height="500"
    title="react-spring-config"
    allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
    sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
></iframe>

## Easings

While react-spring should generally be used to with springs, sometimes parameterizing animations with durations may be required (e.g., timers).

The following easing functions are supported when `duration` is set.

| In            | Out            | In Out           |
| ------------- | -------------- | ---------------- |
| easeInBack    | easeOutBack    | easeInOutBack    |
| easeInBounce  | easeOutBounce  | easeInOutBounce  |
| easeInCirc    | easeOutCirc    | easeInOutCirc    |
| easeInCubic   | easeOutCubic   | easeInOutCubic   |
| easeInElastic | easeOutElastic | easeInOutElastic |
| easeInExpo    | easeOutExpo    | easeInOutExpo    |
| easeInQuad    | easeOutQuad    | easeInOutQuad    |
| easeInQuart   | easeOutQuart   | easeInOutQuart   |
| easeInQuint   | easeOutQuint   | easeInOutQuint   |
| easeInSine    | easeOutSine    | easeInOutSine    |

```lua
api.start({
    position = UDim2.fromScale(0.5, 0.5),
    rotation = 0,
    config = { mass: 10, tension: 100, friction: 50 },
})
```

:::caution ONLY UPDATE IMPERATIVELY
Due to the way easings handle interruptions, it is recommended to only update the spring values imperatively. Setting the target value midway will cause the duration timer to reset.
:::caution

## Advanced Configs

### Velocity Config

When a number, the `velocity` config applies initial velocity towards or away from the target.

```lua
-- Start with initial velocity away from `to`
local styles = RoactSpring.useSpring({
    position = if toggle then UDim2.fromScale(0.5, 0.8) else UDim2.fromScale(0.5, 0.5),
    config = { velocity = -0.01 },
})
```

For further customization on the direction of the velocity, you can pass a table of values, one for each element.

```lua
-- Start with initial velocity pointed towards the top-left corner
local styles = RoactSpring.useSpring({
    position = if toggle then UDim2.fromScale(0.5, 0.8) else UDim2.fromScale(0.5, 0.5),
    config = { velocity = {-0.01, 0, -0.01, 0} },
})
```

Passing in a single number where `to` equals `from` will not move the spring at all. This is because `react-spring` can't determine the direction of the velocity from one point alone. To apply a velocity, you must indicate which axes to apply it to by passing in a table of values.

```lua
-- Will not do anything
local styles = RoactSpring.useSpring({
    position = UDim2.fromScale(0.5, 0.5),
    config = { velocity = -0.01 },
})

-- Will apply velocity towards the top-left corner and then return back to original position
local styles = RoactSpring.useSpring({
    position = UDim2.fromScale(0.5, 0.5),
    config = { velocity = {-0.01, 0, -0.01, 0} },
})
```