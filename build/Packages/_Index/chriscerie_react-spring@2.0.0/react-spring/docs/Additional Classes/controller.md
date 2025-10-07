---
sidebar_position: 10
---

# Controller

## Overview

The `Controller` is roact-spring's heart. All primitives use it internally (including hooks). The api is very similar to the `useSpring` hook.

This should be used when using class components. If you are using hooks, use [useSpring](/docs/hooks/useSpring) instead. Note that the controller's api uses the colon operator unlike the hooks.

```lua
function Example:init()
    self.styles, self.api = RoactSpring.Controller.new({
        size = UDim2.fromOffset(150, 150),
        position = UDim2.fromScale(0.5, 0.5),
    })
end

function Example:render()
	return e("TextButton", {
        Position = self.styles.position,
		Size = self.styles.size,

        [React.Event.Activated] = function()
            self.api:start({
                size = UDim2.fromOffset(150, 150),
                config = { tension = 100, friction = 10 },
            })
        end
	})
end
```

## Demos

### Draggable element

<a href="https://github.com/chriscerie/roact-spring/blob/main/stories/components/SpringDrag.story.lua">
  <img src="https://media.giphy.com/media/R2bJ57MNTdP7vmP6Ez/giphy.gif" width="400" />
</a>