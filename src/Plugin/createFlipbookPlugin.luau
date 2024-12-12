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
}
	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true)

	local widget = plugin:CreateDockWidgetPluginGui(name, info)
	widget.Name = name
	widget.Title = name
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local root = ReactRoblox.createRoot(widget)
	local loader = ModuleLoader.new()
	local button = toolbar:CreateButton(name, "Open story view", "rbxassetid://10277153751")

	local app = React.createElement(ContextProviders, {
		plugin = plugin,
	}, {
		PluginApp = React.createElement(PluginApp, {
			loader = loader,
		}),
	})

	local function unmount()
		root:unmount()
		loader:clear()
	end

	local function mount()
		root:render(app)
	end

	button.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		button:SetActive(widget.Enabled)
	end)

	widget:GetPropertyChangedSignal("Enabled"):Connect(function()
		if widget.Enabled then
			root:render(app)
		else
			unmount()
		end
	end)

	if widget.Enabled then
		mount()
	end

	return {
		mount = mount,
		unmount = unmount,
	}
end

return createFlipbookPlugin
