local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("@root/Plugin/PluginApp")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")

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
		task.spawn(function()
			fireEventAsync({
				eventName = "AppClosed",
			})
		end)
		root:unmount()
	end

	local function mount()
		task.spawn(function()
			fireEventAsync({
				eventName = "AppOpened",
			})
		end)
		root:render(app)
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
