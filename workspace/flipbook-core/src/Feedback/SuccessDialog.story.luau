local React = require("@pkg/React")

local SuccessDialog = require("./SuccessDialog")

return {
	story = function()
		return React.createElement(SuccessDialog, {
			onClose = function()
				print("onClose")
			end,
		})
	end,
}
