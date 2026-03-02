local React = require("@pkg/React")

local StoryError = require("@root/Storybook/StoryError")

return {
	summary = "Component for displaying error messages to the user",
	story = function()
		local _, result = xpcall(function()
			error("Oops!")
		end, debug.traceback)

		return React.createElement(StoryError, {
			errorMessage = result,
		})
	end,
}
