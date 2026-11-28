local AgentGateway = require("@pkg/AgentGateway")

local asDictionary = require("@root/actions/params/asDictionary")
local getOptionalString = require("@root/actions/params/getOptionalString")
local getRequiredString = require("@root/actions/params/getRequiredString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "openStory",
	title = "Open Story",
	description = "Open a Story in Flipbook. Without a storyId, opens the module's first Story.",
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
			storyId = {
				type = "string",
				description = "Optional id of a Story in the module, from listStories",
			},
		} :: { [string]: unknown },
		required = { "story" },
	},
	run = function(controller, rawParams)
		local fields = asDictionary(rawParams)
		return controller.openStory(
			getRequiredString(fields, "story"),
			getOptionalString(fields, "storybook"),
			getOptionalString(fields, "storyId")
		)
	end,
}

return action
