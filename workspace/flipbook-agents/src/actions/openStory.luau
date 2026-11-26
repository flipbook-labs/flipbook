local AgentGateway = require("@pkg/AgentGateway")

local asDictionary = require("@root/actions/params/asDictionary")
local getOptionalString = require("@root/actions/params/getOptionalString")
local getRequiredString = require("@root/actions/params/getRequiredString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "openStory",
	title = "Open Story",
	description = "Open a Story module in Flipbook.",
	inputSchema = {
		type = "object",
		properties = {
			story = {
				type = "string",
				description = "Path to a .story ModuleScript",
			},
			storybook = {
				type = "string",
				description = "Optional path to its .storybook ModuleScript",
			},
		} :: { [string]: unknown },
		required = { "story" },
	},
	run = function(controller, rawParams)
		local fields = asDictionary(rawParams)
		return controller.openStory(getRequiredString(fields, "story"), getOptionalString(fields, "storybook"))
	end,
}

return action
