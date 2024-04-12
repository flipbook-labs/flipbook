local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sidebar = require(script.Parent.Sidebar)
local internalStorybook = require(flipbook["init.storybook"])

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
