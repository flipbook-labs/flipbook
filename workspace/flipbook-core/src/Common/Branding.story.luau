local React = require("@pkg/React")

local Branding = require("./Branding")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

return {
	summary = "Icon and Typography for Flipbook",
	controls = {},
	story = React.createElement(ContextProviders, {
		plugin = MockPlugin.new() :: any,
	}, {
		Branding = React.createElement(Branding),
	}),
}
