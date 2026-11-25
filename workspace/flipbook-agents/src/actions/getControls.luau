local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "getControls",
	title = "Get Controls",
	description = "Return effective control values for the mounted Story as Luau values, such as Color3 or EnumItem.",
	run = function(controller)
		return {
			controls = controller.getControls(),
		}
	end,
}

return action
