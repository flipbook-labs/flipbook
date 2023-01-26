local flipbook = script

local RunService = game:GetService("RunService")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local createWidget = require(flipbook.Plugin.createWidget)
local createToggleButton = require(flipbook.Plugin.createToggleButton)
local App = require(flipbook.Components.App)
local constants = require(flipbook.constants)

local PLUGIN_NAME = "flipbook"

if constants.IS_DEV_MODE then
	_G.__DEV__ = true
	_G.__ROACT_17_MOCK_SCHEDULER__ = true

	PLUGIN_NAME = "flipbook [DEV]"
end

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local root = ReactRoblox.createRoot(widget)
local disconnectButton = createToggleButton(toolbar, widget)

local app = React.createElement(App, {
	plugin = plugin,
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
