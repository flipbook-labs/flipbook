local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local SuccessDialog = require("./SuccessDialog")

return {
	story = function(props)
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
			overlayGui = props.container,
		}, {
			SuccessDialog = React.createElement(SuccessDialog, {
				onClose = function()
					print("onClose")
				end,
			}),
		})
	end,
}
