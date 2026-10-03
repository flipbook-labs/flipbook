local AgentGateway = require("@pkg/AgentGateway")

local asDictionary = require("@root/actions/params/asDictionary")
local getRequiredString = require("@root/actions/params/getRequiredString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "listStories",
	title = "List Stories",
	description = "List Story modules for one available Storybook.",
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
		local fields = asDictionary(rawParams)
		return { stories = controller.listStories(getRequiredString(fields, "storybook")) }
	end,
}

return action
