local React = require("@pkg/React")

local StoryProblemNotice = require("@root/Storybook/StoryProblemNotice")

return {
	summary = "Shown above a Story when its latest edit fails to load",
	story = function()
		return React.createElement(StoryProblemNotice, {
			problem = "Button.story:4: Expected '}' (to close '{' at line 1), got <eof>",
		})
	end,
}
