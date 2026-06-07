local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local Actions = require("@root/Actions")
local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("@root/Plugin/PluginApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local logger = require("@root/logger")

local function stopwatch(callback: () -> ()): string
	local start = os.clock()
	callback()
	return ("%.2fms"):format((os.clock() - start) * 1000)
end

local function createFlipbookPlugin(plugin: Plugin, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local root = ReactRoblox.createRoot(widget)

	-- The central Actions registry. Behavior is defined once and exposed through
	-- two routers: the PluginAction mirror (human shortcuts) and the CoreGui
	-- Bindable registry (agent door). The controller is the seam the actions use
	-- to reach app capabilities; the React app registers its half on mount.
	local controller = Actions.createAppController(widget)
	local registry = Actions.createActionRegistry({
		plugin = plugin,
		controller = controller,
	})
	local unbindPluginActions = Actions.bindPluginActions(plugin, registry)
	local unpublishBindables = Actions.publishBindables(registry)

	-- FIXME: ContextProviders having an error won't fail tests. We really need
	-- a smoketest for this file
	local app = React.createElement(ContextProviders, {
		plugin = plugin,
		overlayGui = widget :: GuiBase2d,
		controller = controller,
	}, {
		PluginApp = React.createElement(PluginApp),
	})

	local function unmount()
		logger:Info("unmounting app...")
		local elapsedMs = stopwatch(function()
			root:unmount()
		end)
		logger:Info(`unmounted app in {elapsedMs}`)

		task.spawn(function()
			fireEventAsync({
				eventName = "AppClosed",
			})
		end)
	end

	local function mount()
		logger:Info("mounting app...")
		local elapsedMs = stopwatch(function()
			root:render(app)
		end)
		logger:Info(`mounted app in {elapsedMs}`)

		task.spawn(function()
			fireEventAsync({
				eventName = "AppOpened",
			})
		end)
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

	table.insert(
		connections,
		widget:GetPropertyChangedSignal("Enabled"):Connect(function()
			if widget.Enabled then
				mount()
			else
				unmount()
			end
		end)
	)

	if widget.Enabled then
		mount()
	end

	local function destroy()
		logger:Info("destroying app...")
		local elapsedMs = stopwatch(function()
			unmount()

			unbindPluginActions()
			unpublishBindables()

			for _, connection in connections do
				connection:Disconnect()
			end
		end)
		logger:Info(`destroyed app in {elapsedMs}`)
	end

	return {
		mount = mount,
		unmount = unmount,
		destroy = destroy,
	}
end

return createFlipbookPlugin
