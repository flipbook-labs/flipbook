local AgentGateway = require("@pkg/AgentGateway")

local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "openViewport",
	title = "Open Viewport",
	description = "Move Flipbook from its widget into the Edit-mode viewport, where screenshots can see it. openWidget moves it back.",
	run = function(controller)
		controller.openViewport()
		return {
			enabled = true,
		}
	end,
}

return action
