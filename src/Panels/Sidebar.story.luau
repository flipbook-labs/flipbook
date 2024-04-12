local React = require("@pkg/React")
local internalStorybook = require("@root/init.storybook.lua")
local Sidebar = require("./Sidebar")

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
