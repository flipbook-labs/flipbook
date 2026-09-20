local AgentGateway = require("@pkg/AgentGateway")

local asDictionary = require("@root/actions/params/asDictionary")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentActions>

local action: Action = {
	name = "setControls",
	title = "Set Controls",
	description = "Set control values for the mounted Story.",
	inputSchema = {
		type = "object",
		properties = {
			controls = {
				type = "object",
				description = "Map of control names to values",
			},
		} :: { [string]: unknown },
		required = { "controls" },
	},
	run = function(controller, rawParams)
		local controls = asDictionary(rawParams).controls
		if type(controls) ~= "table" then
			error("controls must be a table")
		end
		return { controls = controller.setControls(asDictionary(controls)) }
	end,
}

return action
