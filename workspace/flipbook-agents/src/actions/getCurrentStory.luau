local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "getCurrentStory",
	title = "Get Current Story",
	description = "Return the selected concrete Story and its readiness state.",
	run = function(controller)
		return controller.getCurrentStory()
	end,
}

return action
