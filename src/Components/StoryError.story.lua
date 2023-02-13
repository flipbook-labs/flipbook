local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local StoryError = require(script.Parent.StoryError)

return {
	summary = "Component for displaying error messages to the user",
	story = function()
		local _, result = xpcall(function()
			error("Oops!")
		end, debug.traceback)

		return React.createElement(StoryError, {
			err = result,
		})
	end,
}
