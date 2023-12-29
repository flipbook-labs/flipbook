local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local StoryError = require(flipbook.Storybook.StoryError)
local constants = require(flipbook.constants)

local stories = {}

stories.Primary = function()
	local _, result = xpcall(function()
		error("Oops!")
	end, debug.traceback)

	return React.createElement(StoryError, {
		err = result,
	})
end

return {
	summary = "Component for displaying error messages to the user",
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
