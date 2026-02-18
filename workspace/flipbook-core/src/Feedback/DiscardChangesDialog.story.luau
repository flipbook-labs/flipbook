local React = require("@pkg/React")

local DiscardChangesDialog = require("./DiscardChangesDialog")

return {
	story = function()
		return React.createElement(DiscardChangesDialog, {
			onKeepEditing = function()
				print("onKeepEditing")
			end,
			onDiscard = function()
				print("onDiscard")
			end,
		})
	end,
}
