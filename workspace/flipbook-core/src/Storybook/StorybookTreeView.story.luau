local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local StorybookTreeView = require("./StorybookTreeView")

return {
	story = function()
		local storybooks = Storyteller.useStorybooks(game)

		return React.createElement("Frame", {
			Size = UDim2.fromOffset(300, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			StorybookTreeView = React.createElement(StorybookTreeView, {
				storybooks = storybooks,
				onStoryChanged = function(storyModule)
					if storyModule then
						print("selected", storyModule:GetFullName())
					end
				end,
			}),
		})
	end,
}
