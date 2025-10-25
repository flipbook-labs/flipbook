local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local FeedbackDialog = require("./FeedbackDialog")

return {
	story = function(props)
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
			overlayGui = props.container,
		}, {
			FeedbackDialog = React.createElement(FeedbackDialog, {
				onClose = function()
					print("onClose")
				end,
			}),
		})
	end,
}
