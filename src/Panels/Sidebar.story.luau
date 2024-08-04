local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local Sidebar = require("./Sidebar")
local internalStorybook = require("@root/init.storybook.luau")

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new(),
	}, {
		Sidebar = React.createElement(Sidebar, {
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
	}),
}
