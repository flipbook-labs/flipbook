local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local getOptionalString = require("@root/actions/params/getOptionalString")
local getRequiredString = require("@root/actions/params/getRequiredString")
local objectInputSchema = require("@root/actions/objectInputSchema")
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
		local fields = asTable(rawParams)
		return controller.openStory(getRequiredString(fields, "story"), getOptionalString(fields, "storybook"))
	end,
}

return action
