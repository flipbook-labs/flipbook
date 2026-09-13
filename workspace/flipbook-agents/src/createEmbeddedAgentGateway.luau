local AgentGateway = require("@pkg/AgentGateway")

local actions = require("@root/actions")
local types = require("@root/types")

local function createEmbeddedAgentGateway(controller: types.AgentController, parent: Instance): () -> ()
	local config: AgentGateway.Config = {
		name = "FlipbookAgentGateway",
		protocolVersion = 1,
		parent = parent,
	}
	local registry = AgentGateway.createActionRegistry(config, controller, actions.createEmbedded())
	return AgentGateway.createGateway(registry, config)
end

return createEmbeddedAgentGateway
