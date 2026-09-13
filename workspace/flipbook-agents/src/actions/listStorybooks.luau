local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "listStorybooks",
	title = "List Storybooks",
	description = "List Storybooks currently available to Flipbook.",
	run = function(controller)
		return { storybooks = controller.listStorybooks() }
	end,
}

return action
