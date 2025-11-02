local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("@root/Plugin/PluginApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local logging = require("@root/logging")

local function stopwatch(callback: () -> ()): string
	local start = os.clock()
	callback()
	return ("%.2fms"):format((os.clock() - start) * 1000)
end

local function createFlipbookPlugin(plugin: Plugin, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local root = ReactRoblox.createRoot(widget)

	local app = React.createElement(ContextProviders, {
		plugin = plugin,
		overlayGui = widget :: GuiBase2d,
	}, {
		PluginApp = React.createElement(PluginApp),
	})

	local function unmount()
		logging:Info("unmounting app...")
		local elapsedMs = stopwatch(function()
			root:unmount()
		end)
		logging:Info(`unmounted app in {elapsedMs}`)

		task.spawn(function()
			fireEventAsync({
				eventName = "AppClosed",
			})
		end)
	end

	local function mount()
		logging:Info("mounting app...")
		local elapsedMs = stopwatch(function()
			root:render(app)
		end)
		logging:Info(`mounted app in {elapsedMs}`)

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
		logging:Info("destroying app...")
		local elapsedMs = stopwatch(function()
			unmount()

			for _, connection in connections do
				connection:Disconnect()
			end
		end)
		logging:Info(`destroyed app in {elapsedMs}`)
	end

	return {
		mount = mount,
		unmount = unmount,
		destroy = destroy,
	}
end

return createFlipbookPlugin
