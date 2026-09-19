local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")

local CommonTypes = require("@root/Common/types")

type Pluginlike = CommonTypes.Pluginlike

local function createFlipbookPlugin(plugin: Pluginlike, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local agentController = FlipbookAgents.createAgentController(widget)
	local cleanupAgentGateway = FlipbookAgents.createAgentGateway(agentController)
	local app = createFlipbookApp(widget, {
		plugin = plugin,
		overlayGui = widget :: GuiBase2d,
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

	if button ~= nil then
		table.insert(
			connections,
			button.Click:Connect(function()
				widget.Enabled = not widget.Enabled
			end)
		)

		table.insert(
			connections,
			widget:GetPropertyChangedSignal("Enabled"):Connect(function()
				button:SetActive(widget.Enabled)
			end)
		)
	end

	-- Agent discovery must remain available while the widget is hidden.
	mount()

	local function destroy()
		cleanupAgentGateway()
		unmount()

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
