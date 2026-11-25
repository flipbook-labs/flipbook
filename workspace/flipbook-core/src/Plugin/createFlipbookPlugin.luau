local StarterGui = game:GetService("StarterGui")

local AppMode = require("@root/Enums/AppMode")
local FlipbookAgents = require("@workspace/flipbook-agents/src")
local createFlipbookApp = require("@root/createFlipbookApp")
local createPluginAppSurface = require("@root/Plugin/createPluginAppSurface")
local createTelemetry = require("@root/Telemetry/createTelemetry")

local CommonTypes = require("@root/Common/types")

type Pluginlike = CommonTypes.Pluginlike

local function createFlipbookPlugin(plugin: Pluginlike, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	-- Each telemetry client keeps its own consent in memory. The app uses this one
	-- too, so a choice made in its consent dialog or Settings also covers the
	-- AppOpened and AppClosed events sent here.
	local telemetry = createTelemetry(AppMode.PluginWidget, plugin)
	local function fireLifecycleEvent(eventName: "AppOpened" | "AppClosed")
		if eventName == "AppOpened" then
			telemetry.capture({
				eventName = "AppOpened",
			})
		else
			telemetry.capture({
				eventName = "AppClosed",
			})
		end
	end

	local surface = createPluginAppSurface(widget, StarterGui, function(isVisible)
		fireLifecycleEvent(if isVisible then "AppOpened" else "AppClosed")
	end)
	local agentController = FlipbookAgents.createAgentController(widget, surface)
	local cleanupAgentGateway = FlipbookAgents.createAgentGateway(agentController)
	local app = createFlipbookApp(surface.container, {
		plugin = plugin,
		overlayGui = surface.container :: GuiBase2d,
		mode = AppMode.PluginWidget,
		agentController = agentController,
		telemetry = telemetry,
		-- The React tree stays mounted for agent discovery, so surface visibility
		-- owns session telemetry instead of the app lifecycle.
		trackLifecycleTelemetry = false,
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
				button:SetActive(widget.Enabled)
			end)
		)
	end

	-- Agent discovery must remain available while the widget is hidden.
	mount()
	if surface.isVisible() then
		fireLifecycleEvent("AppOpened")
	end

	local function destroy()
		cleanupAgentGateway()
		unmount()
		if surface.isVisible() then
			fireLifecycleEvent("AppClosed")
		end
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
