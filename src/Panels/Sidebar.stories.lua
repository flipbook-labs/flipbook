local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local internalStorybook = require(flipbook["init.storybook"])
local Sidebar = require(script.Parent.Sidebar)

local stories = {}

stories.Primary = React.createElement(Sidebar, {
	storybooks = {
		internalStorybook,
	},
	selectStory = function(storyModule)
		print(storyModule)
	end,
	selectStorybook = function(storybook)
		print(storybook)
	end,
})

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	stories = stories,
}
