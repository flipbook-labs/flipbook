local types = require("@root/Actions/types")

local ToggleWidget: types.Action = {
	id = "Flipbook/ToggleWidget",
	text = "Toggle Flipbook",
	statusTip = "Open or close the Flipbook widget",
	params = {
		{
			name = "enabled",
			type = "boolean",
			required = false,
			description = "Force open (true) or closed (false). Omit to toggle.",
		},
	},
	run = function(ctx, payload)
		local enabled = if typeof(payload) == "table" then payload.enabled else nil
		ctx.controller.toggleWidget(enabled)
		return { widgetOpen = ctx.controller.getState().widgetOpen }
	end,
}

return ToggleWidget
