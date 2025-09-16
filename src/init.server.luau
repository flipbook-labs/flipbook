local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("@root/Plugin/PluginApp")
local PluginStore = require("@root/Plugin/PluginStore")
local createToggleButton = require("@root/Plugin/createToggleButton")
local createWidget = require("@root/Plugin/createWidget")

local PLUGIN_NAME = "Flipbook" .. if _G.BUILD_CHANNEL == "development" then ` {_G.BUILD_HASH}` else ""

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local root = ReactRoblox.createRoot(widget)
local disconnectButton = createToggleButton(toolbar, widget)

PluginStore.get(false).setPlugin(plugin)

local app = React.createElement(ContextProviders, {
	plugin = plugin,
}, {
	PluginApp = React.createElement(PluginApp),
})

local widgetConn = widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		root:render(app)
	else
		root:unmount()
	end
end)

if widget.Enabled then
	root:render(app)
end

plugin.Unloading:Connect(function()
	disconnectButton()
	widgetConn:Disconnect()

	root:unmount()
end)
