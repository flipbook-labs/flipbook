local AgentGateway = require("@pkg/AgentGateway")

type InputSchema = AgentGateway.InputSchema

local function objectInputSchema(properties: { [string]: unknown }, required: { string }?): InputSchema
	return {
		type = "object",
		properties = properties,
		required = required,
	}
end

return objectInputSchema
