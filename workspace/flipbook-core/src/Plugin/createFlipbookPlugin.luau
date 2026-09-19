local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")

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
		-- The React tree stays mounted for agent discovery, so widget visibility
		-- owns session telemetry instead of the app lifecycle.
		trackLifecycleTelemetry = false,
	})
	local isMounted = false
	local isVisible = widget.Enabled

	local function fireLifecycleEvent(eventName: "AppOpened" | "AppClosed")
		task.spawn(function()
			if eventName == "AppOpened" then
				fireEventAsync({
					eventName = "AppOpened",
				})
			else
				fireEventAsync({
					eventName = "AppClosed",
				})
			end
		end)
	end

	local function mount()
		if not isMounted then
			isMounted = true
			app.mount()
		end
	end

	table.insert(
		connections,
		widget:GetPropertyChangedSignal("Enabled"):Connect(function()
			if widget.Enabled ~= isVisible then
				isVisible = widget.Enabled
				fireLifecycleEvent(if isVisible then "AppOpened" else "AppClosed")
			end
		end)
	)

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
	if isVisible then
		fireLifecycleEvent("AppOpened")
	end

	local function destroy()
		cleanupAgentGateway()
		unmount()
		if isVisible then
			isVisible = false
			fireLifecycleEvent("AppClosed")
		end

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
