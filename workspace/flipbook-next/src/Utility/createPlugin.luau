local App = require("@root/Components/App")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local function createPlugin(plugin: Plugin, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local root = ReactRoblox.createRoot(widget)
	local app = React.createElement(App)

	local function mount()
		root:render(app)
	end

	local function unmount()
		root:unmount()
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
		destroy = destroy,
		mount = mount,
		unmount = unmount,
	}
end

return createPlugin
