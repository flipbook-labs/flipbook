local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "getControls",
	title = "Get Controls",
	description = "Return effective control values for the mounted Story.",
	run = function(controller)
		return { controls = controller.getControls() }
	end,
}

return action
