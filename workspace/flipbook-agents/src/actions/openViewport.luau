local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "openViewport",
	title = "Open Viewport",
	description = "Move Flipbook into an Edit-mode ScreenGui visible in the Studio viewport.",
	run = function(controller)
		controller.openViewport()
		return { surface = "viewport" }
	end,
}

return action
