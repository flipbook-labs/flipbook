local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local NoStorySelected = require("./NoStorySelected")

return {
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new(),
	}, {
		NoStorySelected = React.createElement(NoStorySelected),
	}),
}
