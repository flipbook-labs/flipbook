local AgentGateway = require("@pkg/AgentGateway")

local objectInputSchema = require("@root/actions/objectInputSchema")
local params = require("@root/actions/params")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "openStory",
	title = "Open Story",
	description = "Open a Story module in Flipbook.",
	inputSchema = objectInputSchema({
		story = { type = "string", description = "Path to a .story ModuleScript" },
		storybook = { type = "string", description = "Optional path to its .storybook ModuleScript" },
	}, { "story" }),
	run = function(controller, rawParams)
		local fields = params.asTable(rawParams)
		return controller.openStory(
			params.getRequiredString(fields, "story"),
			params.getOptionalString(fields, "storybook")
		)
	end,
}

return action
