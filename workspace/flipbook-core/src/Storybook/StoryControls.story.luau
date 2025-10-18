local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryControls = require("@root/Storybook/StoryControls")

return {
	summary = "Panel for configuring the controls of a story",
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			StoryControls = React.createElement(StoryControls, {
				controls = {
					foo = "bar",
					checkbox = false,
					number = 10,
					dropdown = {
						"Option 1",
						"Option 2",
						"Option 3",
					},
					onlyTwentyCharacters = "OnlyTwentyCharacters",
					badControlType = function() end,
				},
				modifiedControls = {},
				setControl = function() end,
			}),
		})
	end,
}
