local React = require("@pkg/react")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryError = require("@root/Storybook/StoryError")

return {
	summary = "Component for displaying error messages to the user",
	story = function()
		local _, result = xpcall(function()
			error("Oops!")
		end, debug.traceback)

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			StoryError = React.createElement(StoryError, {
				err = result,
			}),
		})
	end,
}
