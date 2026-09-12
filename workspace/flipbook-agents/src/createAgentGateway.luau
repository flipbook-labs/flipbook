local AgentGateway = require("@pkg/AgentGateway")

local actions = require("@root/actions")
local types = require("@root/types")

local CONFIG: AgentGateway.Config = {
	name = "FlipbookAgentGateway",
	protocolVersion = 1,
}

local function createAgentGateway(controller: types.AgentController): () -> ()
	local registry = AgentGateway.createActionRegistry(CONFIG, controller, actions.create())
	return AgentGateway.createGateway(registry, CONFIG)
end

return createAgentGateway
