local AgentGateway = require("@pkg/AgentGateway")

local asDictionary = require("@root/actions/params/asDictionary")
local getOptionalString = require("@root/actions/params/getOptionalString")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "listStories",
	title = "List Stories",
	description = "List every Story, with its id, for one available Storybook, or for orphaned Story modules when no Storybook is provided. A module that is still loading is listed once with status Loading; call again to get its Stories.",
	inputSchema = {
		type = "object",
		properties = {
			storybook = {
				type = "string",
				description = "Optional path to a .storybook ModuleScript. Omit it to list orphaned Stories.",
			},
		} :: { [string]: unknown },
	},
	run = function(controller, rawParams)
		local fields = asDictionary(rawParams)
		return {
			stories = controller.listStories(getOptionalString(fields, "storybook")),
		}
	end,
}

return action
