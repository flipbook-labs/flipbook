local navigationEnums = require("@root/Navigation/enums")
local types = require("@root/Actions/types")

local NavigateTo: types.Action = {
	id = "Flipbook/NavigateTo",
	text = "Navigate",
	statusTip = "Switch to a Flipbook screen (Home, Settings, About, Logs)",
	-- Payload-required, so not a useful static shortcut. The PluginAction mirror
	-- would have no screen to navigate to.
	allowBinding = false,
	params = {
		{
			name = "screen",
			type = "string",
			required = true,
			description = "One of: Home, Settings, About, Logs",
		},
	},
	run = function(ctx, payload)
		assert(typeof(payload) == "table" and typeof(payload.screen) == "string", "payload.screen (string) is required")
		assert(navigationEnums.Screen[payload.screen] ~= nil, `unknown screen: {payload.screen}`)
		return ctx.controller.navigateTo(payload.screen)
	end,
}

return NavigateTo
