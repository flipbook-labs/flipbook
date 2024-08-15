local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StoryError = require("@root/Storybook/StoryError")
local constants = require("@root/constants")

local stories = {}

stories.Primary = function()
	local _, result = xpcall(function()
		error("Oops!")
	end, debug.traceback)

	return React.createElement(ContextProviders, {
		plugin = MockPlugin.new(),
	}, {
		StoryError = React.createElement(StoryError, {
			err = result,
		}),
	})
end

return {
	summary = "Component for displaying error messages to the user",
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
