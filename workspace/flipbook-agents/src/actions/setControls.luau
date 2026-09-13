local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local objectInputSchema = require("@root/actions/objectInputSchema")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "setControls",
	title = "Set Controls",
	description = "Set control values for the mounted Story.",
	inputSchema = objectInputSchema({
		controls = { type = "object", description = "Map of control names to values" },
	}, { "controls" }),
	run = function(controller, rawParams)
		local controls = asTable(rawParams).controls
		if type(controls) ~= "table" then
			error("controls must be a table")
		end
		for key in controls :: { [unknown]: unknown } do
			if type(key) ~= "string" then
				error("control names must be strings")
			end
		end
		return { controls = controller.setControls(controls :: { [string]: unknown }) }
	end,
}

return action
