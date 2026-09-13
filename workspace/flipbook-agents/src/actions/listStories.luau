local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local getRequiredString = require("@root/actions/params/getRequiredString")
local objectInputSchema = require("@root/actions/objectInputSchema")
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
		local fields = asTable(rawParams)
		return { stories = controller.listStories(getRequiredString(fields, "storybook")) }
	end,
}

return action
