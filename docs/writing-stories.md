---
sidebar_position: 2
---

# Writing Stories

flipbook uses the concept of "storybooks" and "stories." A storybook is used to tell flipbook where to look for stories, and a story tells flipbook what Roact component should be mounted, along with an optional summary and controls to help you with writing different states for your components.

## Storybook

Every project needs a storybook, so to get started you will create a new `ProjectName.storybook.luau` file at the root of your project with the following contents:

```lua
-- src/ProjectName.storybook.luau

-- Make sure to adjust the path to Roact if needed
local Roact = require(path.to.Roact)

return {
    roact = Roact,
    storyRoots = {
        script.Parent.Components
    }
}
```

When flipbook reads this file, it will use the copy of Roact given for each of your stories, and it will search in `script.Parent.Components` for all of your story files.

Right now you should see a single entry in flipbook's sidebar for this storybook. Let's add a story to liven things up!

## Story

A story and its associated component should be in two separate files. Both files should share the same name, however the story will end with `.story`. To get started, let's create `Button.luau` and `Button.story.luau`:

```lua
-- src/Components/Button.luau

local Roact = require(path.to.Roact)

type Props = {
	text: string,
	onActivated: (() -> ())?,
}

local function Button(props)
	return Roact.createElement("TextButton", {
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(239, 31, 90),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
		[Roact.Event.Activated] = props.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return Button
```

And now let's write the story to mount the Button component:

```lua
-- src/Components/Button.story.luau

local Roact = require(path.to.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "A generic button component that can be used anywhere",
	story = Roact.createElement(Button, {
		text = "Click me",
		onActivated = function()
			print("click")
		end,
	}),
}
```

In the sidebar for flipbook you should now see your newly created Button story. Go ahead and select it to view the button you just created.

<!-- TODO: Add image of the button in flipbook -->

Writing stories can significantly improve your experience while developing Roact components.It's recommended that you create a story for each component so that you work on them in isolation to build up a strong foundation for your app.

### Controls

flipbook also has the feature of "controls" where you can specify configurable values that get passed down into your component.

We will continue with our Button component and give it a "disabled" state for when we don't want a user to be able to interact with it:

```diff
type Props = {
	text: string,
+   isDisabled: boolean?,
	onActivated: (() -> ())?,
}

local function Button(props)
+ 	local color = if props.isDisabled then Color3.fromRGB(82, 82, 82) else Color3.fromRGB(239, 31, 90)

	return Roact.createElement("TextButton", {
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
-       BackgroundColor3 = Color3.fromRGB(239, 31, 90),
+		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
-		[Roact.Event.Activated] = props.onActivated,
+		[Roact.Event.Activated] = if props.isDisabled then nil else props.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return Button
```

And now modify the story to pass in the `isDisabled` prop:

```diff
local Roact = require(path.to.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "A generic button component that can be used anywhere",
	story = Roact.createElement(Button, {
		text = "Click me",
+       isDisabled = true,
		onActivated = function()
			print("click")
		end,
	}),
}
```

The story should automatically reload and you will see the button is greyed out and no longed prints "click" when activated.

<!-- Add image of button with disabled state -->

Despite this new `isDisabled` prop, it is still hard to test out different state sfor the button since you have to manually edit the story each time. That's where controls come in. Modify your story as follows:

```diff
local Roact = require(path.to.Roact)
local Button = require(script.Parent.Button)

return {
	summary = "A generic button component that can be used anywhere",
+	controls = {
+		isDisabled = false,
+	},
-	story = Roact.createElement(Button, {
+	story = function(props)
+		return Roact.createElement(Button, {
			text = "Click me",
-			isDisabled = true,
+			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
+	end,
}
```

With this change, a new "Controls" panel will appear where you can toggle the `isDisabled` prop. This gets fed into your Button component and will automatically reload. You can now toggle between your button's states to see how it behaves.

<!-- TODO: Add image of Controls panel -->

## Next Steps

You have just been given an example of how to create a storybook and a story for a Button component that makes use of flipbook's controls feature. This document outlines the biggest features of flipbook, but there are other options you can play around with.

Check out [Story Format](story-format.md) next to learn about all the options you have available.
