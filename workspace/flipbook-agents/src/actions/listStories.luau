local AgentGateway = require("@pkg/AgentGateway")

local objectInputSchema = require("@root/actions/objectInputSchema")
local params = require("@root/actions/params")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "listStories",
	title = "List Stories",
	description = "List Story modules for one available Storybook.",
	inputSchema = objectInputSchema({
		storybook = { type = "string", description = "Path to a .storybook ModuleScript" },
	}, { "storybook" }),
	run = function(controller, rawParams)
		local fields = params.asTable(rawParams)
		return { stories = controller.listStories(params.getRequiredString(fields, "storybook")) }
	end,
}

return action
