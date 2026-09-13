local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local getOptionalString = require("@root/actions/params/getOptionalString")
local getRequiredString = require("@root/actions/params/getRequiredString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "openStory",
	title = "Open Story",
	description = "Open a concrete Story in Flipbook, defaulting to the module's first Story.",
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
				description = "Optional concrete Story ID",
			},
		} :: { [string]: unknown },
		required = { "story" },
	},
	run = function(controller, rawParams)
		local fields = asTable(rawParams)
		return controller.openStory(
			getRequiredString(fields, "story"),
			getOptionalString(fields, "storybook"),
			getOptionalString(fields, "storyId")
		)
	end,
}

return action
