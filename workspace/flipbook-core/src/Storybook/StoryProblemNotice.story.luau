local React = require("@pkg/React")

local StoryProblemNotice = require("@root/Storybook/StoryProblemNotice")

return {
	summary = "Shown above a Story when its latest edit fails to load",
	story = function()
		return React.createElement(StoryProblemNotice, {
			problem = "ReplicatedStorage.Components.ButtonStyles:12: attempt to index nil with 'Padding'",
		})
	end,
}
