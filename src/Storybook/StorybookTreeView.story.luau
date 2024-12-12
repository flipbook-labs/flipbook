local ModuleLoader = require("@pkg/ModuleLoader")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StorybookTreeView = require("./StorybookTreeView")

local loader = ModuleLoader.new()

local function Story()
	local storybooks = Storyteller.useStorybooks(game, loader)

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
end

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			Story = React.createElement(Story),
		})
	end,
}
