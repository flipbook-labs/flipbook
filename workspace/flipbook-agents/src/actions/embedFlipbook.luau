local AgentGateway = require("@pkg/AgentGateway")

local objectInputSchema = require("@root/actions/objectInputSchema")
local params = require("@root/actions/params")
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
		local fields = params.asTable(rawParams)
		return {
			path = controller.embedFlipbook(
				params.getOptionalString(fields, "parent"),
				params.getOptionalBoolean(fields, "overwrite")
			),
		}
	end,
}

return action
