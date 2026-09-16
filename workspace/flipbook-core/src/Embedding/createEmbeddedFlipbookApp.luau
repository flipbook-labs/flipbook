local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")

local function createEmbeddedFlipbookApp(screenGui: ScreenGui)
	local gatewayParent = screenGui.Parent
	assert(gatewayParent ~= nil, "embedded ScreenGui must be parented")

	local agentController = FlipbookAgents.createAgentController(function()
		screenGui.Enabled = true
	end)
	local app = createFlipbookApp(screenGui, {
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
