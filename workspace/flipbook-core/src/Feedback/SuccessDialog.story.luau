local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local SuccessDialog = require("./SuccessDialog")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			SuccessDialog = React.createElement(SuccessDialog, {
				onClose = function()
					print("onClose")
				end,
			}),
		})
	end,
}
