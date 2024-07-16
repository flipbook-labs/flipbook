local React = require("@pkg/React")
local Sidebar = require("./Sidebar")
local internalStorybook = require("@root/init.storybook.luau")

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = React.createElement(Sidebar, {
		storybooks = {
			internalStorybook,
		},
		selectStory = function(storyModule)
			print(storyModule)
		end,
		selectStorybook = function(storybook)
			print(storybook)
		end,
	}),
}
