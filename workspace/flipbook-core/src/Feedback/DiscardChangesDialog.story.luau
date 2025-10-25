local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local DiscardChangesDialog = require("./DiscardChangesDialog")

return {
	story = function(props)
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
			overlayGui = props.container,
		}, {
			DiscardChangesDialog = React.createElement(DiscardChangesDialog, {
				onKeepEditing = function()
					print("onKeepEditing")
				end,
				onDiscard = function()
					print("onDiscard")
				end,
			}),
		})
	end,
}
