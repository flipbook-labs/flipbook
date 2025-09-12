local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local StorybookError = require("@root/Storybook/StorybookError")

type UnavailableStorybook = Storyteller.UnavailableStorybook

return {
	summary = "Component for displaying error messages to the user",
	story = function()
		local storybookModule = script.Parent.Parent["init.storybook"]
		local unavailableStorybook: UnavailableStorybook = {
			problem = "Something went wrong!",
			storybook = {
				name = storybookModule.Name,
				source = storybookModule,
				loader = {} :: any,
				storyRoots = {},
			},
		}

		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			StorybookError = React.createElement(StorybookError, {
				unavailableStorybook = unavailableStorybook,
			}),
		})
	end,
}
