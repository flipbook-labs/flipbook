local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Sidebar = require("./Sidebar")

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = function()
		local storybooks = Storyteller.useStorybooks(game)

		return React.createElement(Sidebar, {
			storybooks = storybooks,
			onStoryChanged = function(storyModule, storybook)
				print("storyModule", storyModule)
				print("storybook", storybook)
			end,
			onShowErrorPage = function(unavailableStorybook)
				print("unavailableStorybook", unavailableStorybook)
			end,
		})
	end,
}
