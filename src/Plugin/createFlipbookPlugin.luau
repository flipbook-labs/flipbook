local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local ModuleLoader = require("@pkg/ModuleLoader")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("@root/Plugin/PluginApp")

local function createFlipbookPlugin(
	name: string,
	plugin: Plugin,
	toolbar: PluginToolbar
): {
	mount: () -> (),
	unmount: () -> (),
	destroy: () -> (),
}
	local isDestroyed = false

	local connections: { RBXScriptConnection } = {}

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true)

	local widget = plugin:CreateDockWidgetPluginGui(name, info)
	widget.Name = name
	widget.Title = name
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local root = ReactRoblox.createRoot(widget)
	local loader = ModuleLoader.new()
	local button = toolbar:CreateButton(name, "Open story view", "rbxassetid://10277153751")

	local function unmount()
		assert(not isDestroyed, "cannot call unmount (Flipbook plugin was destroyed)")

		root:unmount()
		loader:clear()

		for _, connection in connections do
			connection:Disconnect()
		end
	end

	local function mount()
		assert(not isDestroyed, "cannot call mount (Flipbook plugin was destroyed)")

		local app = React.createElement(ContextProviders, {
			plugin = plugin,
		}, {
			PluginApp = React.createElement(PluginApp, {
				loader = loader,
			}),
		})

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

		table.insert(
			connections,
			widget:GetPropertyChangedSignal("Enabled"):Connect(function()
				if widget.Enabled then
					root:render(app)
				else
					unmount()
				end
			end)
		)

		table.insert(connections, plugin.Unloading:Connect(unmount))

		if widget.Enabled then
			root:render(app)
		end
	end

	local function destroy()
		assert(not isDestroyed, "cannot call destroy (Flipbook plugin was already destroyed)")

		unmount()

		isDestroyed = true

		widget:Destroy()
		toolbar:Destroy()
		button:Destroy()
		root = nil :: any
		loader = nil :: any
	end

	return {
		mount = mount,
		unmount = unmount,
		destroy = destroy,
	}
end

return createFlipbookPlugin
