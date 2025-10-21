local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local FeedbackDialog = require("./FeedbackDialog")

return {
	story = function()
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			FeedbackDialog = React.createElement(FeedbackDialog, {
				onClose = function()
					print("onClose")
				end,
			}),
		})
	end,
}
