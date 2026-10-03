local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "openWidget",
	title = "Open Widget",
	description = "Open the Flipbook plugin widget.",
	run = function(controller)
		controller.openWidget()
		return { enabled = true }
	end,
}

return action
