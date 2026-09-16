local StarterGui = game:GetService("StarterGui")

local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")
local createPluginAppSurface = require("@root/Plugin/createPluginAppSurface")

local CommonTypes = require("@root/Common/types")

type Pluginlike = CommonTypes.Pluginlike

local function createFlipbookPlugin(plugin: Pluginlike, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local surface = createPluginAppSurface(widget, StarterGui)
	local agentController = FlipbookAgents.createAgentController(surface.openWidget, surface.openViewport, function()
		if not surface.isVisible() then
			surface.openWidget()
		end
	end)
	local cleanupAgentGateway = FlipbookAgents.createAgentGateway(agentController)
	local app = createFlipbookApp(surface.container, {
		plugin = plugin,
		overlayGui = surface.container :: GuiBase2d,
		mode = AppMode.PluginWidget,
		agentController = agentController,
	})
	local isMounted = false

	local function mount()
		if not isMounted then
			isMounted = true
			app.mount()
		end
	end

	local function unmount()
		if isMounted then
			isMounted = false
			app.unmount()
		end
	end

	local function syncVisibility()
		if surface.isVisible() then
			mount()
		else
			unmount()
		end
	end

	local cleanupVisibilityConnection = surface.onVisibilityChanged(syncVisibility)

	if button ~= nil then
		table.insert(
			connections,
			button.Click:Connect(function()
				if surface.getName() == "viewport" then
					surface.openWidget()
				else
					widget.Enabled = not widget.Enabled
				end
			end)
		)

		table.insert(
			connections,
			widget:GetPropertyChangedSignal("Enabled"):Connect(function()
				button:SetActive(surface.getName() == "widget" and widget.Enabled)
			end)
		)
	end

	syncVisibility()

	local function destroy()
		cleanupAgentGateway()
		cleanupVisibilityConnection()
		unmount()
		surface.destroy()

		for _, connection in connections do
			connection:Disconnect()
		end
	end

	return {
		mount = mount,
		unmount = unmount,
		destroy = destroy,
	}
end

return createFlipbookPlugin
