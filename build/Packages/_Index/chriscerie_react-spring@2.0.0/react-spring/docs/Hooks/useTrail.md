---
sidebar_position: 3
---

# useTrail

## Overview

Creates multiple springs with a single config, each spring will follow the previous one. Use it for staggered animations.

### Either: declaratively overwrite values to change the animation

If you re-render the component with changed props, the animation will update.

```lua
local springProps = {}
local length = #items
for index, item in ipairs(items) do
    table.insert(springProps, {
        transparency = if toggles[i] then 1 else 0,
    })
end
local springs = RoactSpring.useTrail(length, springProps)
```

If you want the animation to run on mount, you can use `from` to set the initial value.

```lua
local springProps = {}
local length = #items
for index, item in ipairs(items) do
    table.insert(springProps, {
        from = { transparency = item.transparency },
        to = { transparency = if toggles[i] then 1 else 0 },
    })
end
local springs = RoactSpring.useTrail(length, springProps)
```

### Or: pass a function that returns values, and imperatively update using the api

You will get an API table back. It will not automatically animate on mount and re-render, but you can call `api.start` to start the animation. Handling updates like this is generally preferred as it's more powerful. Further documentation can be found in [Imperatives](/docs/common/imperatives).

```lua
local length = #items
local springs, api = RoactSpring.useTrail(length, function(index)
    return { transparency = items[index].transparency }
end)

-- Start animations
api.start(function(index)
    return { position = UDim2.fromScale(0.5 * index, 0.16) }
end)
-- Stop all springs
api.stop()
```

### Finally: apply styles to components

```lua
local contents = {}
for i = 1, 4 do
    contents[i] = React.createElement("Frame", {
        Position = springs[i].position,
        Size = UDim2.fromScale(0.3, 0.3),
    })
end
return contents
```

## Properties

All properties documented in the [common props](/docs/common/props) apply.

By default, each spring will start 0.1 seconds after the previous one. You can override this by passing a `delay` property.

```lua
-- Now each spring will start 0.2 seconds after the previous one
local springs, api = RoactSpring.useTrail(length, function(index)
    return {
        transparency = items[index].transparency,
        delay = 0.2,
    }
end)
```

You can also pass a `delay` property to each spring individually.
```lua
-- The first spring will start 0.1 seconds after the previous one, the second 0.2 seconds, and so on
local springs, api = RoactSpring.useTrail(length, function(index)
    return {
        transparency = items[index].transparency,
        delay = index * 0.1,
    }
end)
```

## Demos

### Staggered list

<a href="https://github.com/chriscerie/roact-spring/blob/main/stories/hooks/useTrailList.story.lua">
  <img src="https://media.giphy.com/media/XfG0GNKGCKang91lLN/giphy.gif" width="400" />
</a>

### Staggered text

<a href="https://github.com/chriscerie/roact-spring/blob/main/stories/hooks/useTrailText.story.lua">
  <img src="https://media.giphy.com/media/9llkynmhlsUvZCupPz/giphy.gif" width="300" />
</a>

### Trailing elements

<a href="https://github.com/chriscerie/roact-spring/blob/main/stories/hooks/useTrailFollow.story.lua">
  <img src="https://media.giphy.com/media/BS20XRr522AJgkCyZR/giphy.gif" width="400" />
</a>