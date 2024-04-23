local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local ModuleLoader = require("@pkg/ModuleLoader")
local PluginApp = require("@root/Plugin/PluginApp")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local constants = require("@root/constants")
local createToggleButton = require("@root/Plugin/createToggleButton")
local createWidget = require("@root/Plugin/createWidget")

local PLUGIN_NAME = "flipbook"

if constants.IS_DEV_MODE then
	PLUGIN_NAME = "flipbook [DEV]"
end

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local root = ReactRoblox.createRoot(widget)
local disconnectButton = createToggleButton(toolbar, widget)

local loader = ModuleLoader.new()

local app = React.createElement(PluginApp, {
	plugin = plugin,
	loader = loader,
})

local widgetConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		root:render(app)
	else
		root:unmount()
		loader:clear()
	end
end)

if widget.Enabled then
	root:render(app)
end

plugin.Unloading:Connect(function()
	disconnectButton()
	widgetConn:Disconnect()

	root:unmount()
	loader:clear()
end)
