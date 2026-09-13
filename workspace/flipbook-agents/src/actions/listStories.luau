local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local getRequiredString = require("@root/actions/params/getRequiredString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "listStories",
	title = "List Stories",
	description = "List every concrete Story for one available Storybook.",
	inputSchema = {
		type = "object",
		properties = {
			storybook = {
				type = "string",
				description = "Path to a .storybook ModuleScript",
			},
		} :: { [string]: unknown },
		required = { "storybook" },
	},
	run = function(controller, rawParams)
		local fields = asTable(rawParams)
		return { stories = controller.listStories(getRequiredString(fields, "storybook")) }
	end,
}

return action
