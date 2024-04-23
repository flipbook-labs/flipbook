local React = require("@pkg/React")
local StoryControls = require("@root/Storybook/StoryControls")

local stories = {}

stories.Primary = React.createElement(StoryControls, {
	controls = {
		foo = "bar",
		checkbox = false,
		dropdown = {
			"Option 1",
			"Option 2",
			"Option 3",
		},
	},
	setControl = function() end,
})

return {
	summary = "Panel for configuring the controls of a story",
	stories = stories,
}
