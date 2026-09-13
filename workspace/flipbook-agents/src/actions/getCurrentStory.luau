local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "getCurrentStory",
	title = "Get Current Story",
	description = "Return the selected Story and whether its view is mounted.",
	run = function(controller)
		return controller.getCurrentStory()
	end,
}

return action
