local React = require("@pkg/react")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local NoStorySelected = require("./NoStorySelected")

return {
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
	}, {
		NoStorySelected = React.createElement(NoStorySelected),
	}),
}
