local React = require("@pkg/React")

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
