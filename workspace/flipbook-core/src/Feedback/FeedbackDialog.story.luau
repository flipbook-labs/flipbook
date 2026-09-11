local React = require("@pkg/React")

local FeedbackDialog = require("./FeedbackDialog")

return {
	story = function()
		return React.createElement(FeedbackDialog, {
			onClose = function()
				print("onClose")
			end,
		})
	end,
}
