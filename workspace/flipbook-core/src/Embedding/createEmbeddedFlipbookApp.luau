local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")
local types = require("@root/Embedding/types")

type LaunchData = types.LaunchData

local function createEmbeddedFlipbookApp(screenGui: ScreenGui, launchData: LaunchData?)
	local gatewayParent = screenGui.Parent
	assert(gatewayParent ~= nil, "embedded ScreenGui must be parented")

	local agentController = FlipbookAgents.createAgentController(function()
		screenGui.Enabled = true
	end)
	local app = createFlipbookApp(screenGui, {
		launchData = launchData,
		overlayGui = screenGui :: GuiBase2d,
		mode = AppMode.EmbeddedClient,
		agentController = agentController,
	})

	app.mount()
	local cleanupAgentGateway = FlipbookAgents.createEmbeddedAgentGateway(agentController, gatewayParent)

	local function destroy()
		cleanupAgentGateway()
		app.destroy()
	end

	return {
		mount = app.mount,
		unmount = app.unmount,
		destroy = destroy,
	}
end

return createEmbeddedFlipbookApp
