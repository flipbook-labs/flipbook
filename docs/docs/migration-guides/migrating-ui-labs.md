# UI Labs

[Hoarcekat](https://github.com/Kampfkarren/hoarcekat/) is a popular storybook plugin like flipbook. Because of its popularity, its story format is supported by flipbook so that you have an easier time migrating.

:::note
This guide assumes you are using [Rojo](https://github.com/rojo-rbx/rojo/) to manage your source code. If you are not then your mileage may vary.
:::

## Creating the Storybook

The main difference in how flipbook and Hoarcekat handle stories is that flipbook requires a "storybook" file to know where your stories are. As such, to migrate over from Hoarcekat the first thing you should do is create a storybook for your project.

To do this, create a new `ProjectName.storybook.luau` file at the root of your project with the following contents:

```lua
-- Make sure to adjust the path to Roact if needed
local Roact = require(script.Parent.Parent.Roact)

return {
    roact = Roact,
    storyRoots = {
        script.Parent.Components
    }
}
```

From there the storybook will appear in flipbook's sidebar and you should be able to select your stories with no problem.

## Migrating Stories

To fully benefit from the features flipbook has to offer, this section will guide you in converting an existing Hoarcekat story to flipbook's format.

We will use the following component and story as an example:

```lua
-- HelloWorld.luau
type Props = {
    name: string?
}

local function HelloWorld(props: Props)
    local name = props.name or "World"

    return Roact.createElement("TextLabel", {
        Text = ("Hello %s!"):format(name),
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        Size = UDim2.fromOffset(200, 100),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    })
end

return HelloWorld
```

```lua
-- HelloWorld.story.luau
local Roact = require(script.Parent.Parent.Roact)
local HelloWorld = require(script.Parent.HelloWorld)

return function(target)
    local root = Roact.createElement(HelloWorld, {
        name = "flipbook"
    })

    local handle = Roact.mount(root, target)

    return function()
        Roact.unmount(handle)
    end
end
```

<!-- TODO: Add image of the story -->

Converting a Hoarcekat story like this into one compatible with flipbook is quite easy. In fact, all that's needed from the above story is the call to `Roact.createElement`:

```lua
-- HelloWorld.story.luau
local Roact = require(script.Parent.Parent.Roact)
local HelloWorld = require(script.Parent.HelloWorld)

return {
    story = Roact.createElement(HelloWorld, {
        name = "flipbook"
    })
}
```

Since flipbook assumes use of Roact, you don't have to handle mounting and unmounting yourself. And now that the story has been migrated we can start supercharging it. For starters, we can give the story a summary that will be displayed when viewing it:

```diff
local Roact = require(script.Parent.Parent.Roact)
local HelloWorld = require(script.Parent.HelloWorld)

return {
+   summary = "This is a Hoarcekat component that has been converted for flipbook!"
    story = Roact.createElement(HelloWorld, {
        name = "flipbook"
    })
}
```

<!-- TODO: Add image of the story -->

Next lets add some controls so we can change the `name` prop without having to manually modify the story:

```diff
local Roact = require(script.Parent.Parent.Roact)
local HelloWorld = require(script.Parent.HelloWorld)

return {
    summary = "This is a Hoarcekat component that has been converted for flipbook!"
+   controls = {
+       name = "flipbook"
+   }
+   story = return function(props)
+       return Roact.createElement(HelloWorld, {
+           name = props.controls.name
+       })
+   end
}
```

You will now have a "Controls" section with an input field. Try changing the value to see your component update live.

<!-- TODO: Add image of the story -->

You are now equipped to migrate your other Hoarcekat stories over to flipbook!

## Further Reading

- [Writing Stories](writing-stories.md)
- [Story Format](story-format.md)
