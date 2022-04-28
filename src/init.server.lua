local RunService = game:GetService("RunService")

local Roact = require(script.Packages.Roact)
local createWidget = require(script.Modules.createWidget)
local createToggleButton = require(script.Modules.createToggleButton)
local App = require(script.Components.App)

local IS_DEV = false
local PLUGIN_NAME = "flipbook"

if IS_DEV then
	Roact.setGlobalConfig({
		elementTracing = true,
	})

	PLUGIN_NAME = "flipbook [DEV]"
end

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local disconnectButton = createToggleButton(toolbar, widget)

local handle: any

local widgetConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		handle = Roact.mount(Roact.createElement(App), widget, "App")
	else
		Roact.unmount(handle)
		handle = nil
	end
end)

if widget.Enabled then
	handle = Roact.mount(Roact.createElement(App), widget, "App")
end

plugin.Unloading:Connect(function()
	disconnectButton()
	widgetConn:Disconnect()

	if handle then
		Roact.unmount(handle)
	end
end)
