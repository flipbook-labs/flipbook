local AgentGateway = require("@pkg/AgentGateway")

local asTable = require("@root/actions/params/asTable")
local getOptionalBoolean = require("@root/actions/params/getOptionalBoolean")
local getOptionalString = require("@root/actions/params/getOptionalString")
local objectInputSchema = require("@root/actions/objectInputSchema")
local types = require("@root/types")

type Action = AgentGateway.Action<types.AgentController>

local action: Action = {
	name = "embedFlipbook",
	title = "Embed Flipbook",
	description = "Embed the Flipbook runtime into the experience for Play-mode input and screenshots.",
	inputSchema = objectInputSchema({
		parent = {
			type = "string",
			description = "Optional destination path. Defaults to ReplicatedStorage.",
		},
		overwrite = { type = "boolean", description = "Replace an existing embedded Flipbook runtime." },
	}, nil),
	run = function(controller, rawParams)
		local fields = asTable(rawParams)
		return {
			path = controller.embedFlipbook(
				getOptionalString(fields, "parent"),
				getOptionalBoolean(fields, "overwrite")
			),
		}
	end,
}

return action
