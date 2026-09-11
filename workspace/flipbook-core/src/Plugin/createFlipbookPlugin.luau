local AppMode = require("@root/Enums/AppMode")
local createAgentGateway = require("@root/Agent/createAgentGateway")
local createFlipbookApp = require("@root/createFlipbookApp")

local CommonTypes = require("@root/Common/types")

type Pluginlike = CommonTypes.Pluginlike

local function createFlipbookPlugin(plugin: Pluginlike, widget: DockWidgetPluginGui, button: PluginToolbarButton?)
	local connections: { RBXScriptConnection } = {}
	local cleanupAgentGateway = createAgentGateway(plugin, widget)
	local app = createFlipbookApp(widget, {
		plugin = plugin,
		overlayGui = widget :: GuiBase2d,
		mode = AppMode.PluginWidget,
	})

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
				app.mount()
			else
				app.unmount()
			end
		end)
	)

	if widget.Enabled then
		app.mount()
	end

	local function destroy()
		cleanupAgentGateway()
		app.destroy()

		for _, connection in connections do
			connection:Disconnect()
		end
	end

	return {
		mount = app.mount,
		unmount = app.unmount,
		destroy = destroy,
	}
end

return createFlipbookPlugin
