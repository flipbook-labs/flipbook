local React = require("@pkg/react")

local AboutView = require("./AboutView")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			AboutView = React.createElement(AboutView),
		})
	end,
}
