local flipbook = script

local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local DEV_MODE = flipbook:FindFirstChild("DEV_MODE")

if DEV_MODE then
	local runTests = require(flipbook.Testing.runTests)

	-- Dev mode must be enabled before React is ever required
	_G.__DEV__ = true

	runTests(flipbook)
end

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local createWidget = require(flipbook.Plugin.createWidget)
local createToggleButton = require(flipbook.Plugin.createToggleButton)
local PluginApp = require(flipbook.Plugin.PluginApp)

local PLUGIN_NAME = "flipbook"

if DEV_MODE then
	PLUGIN_NAME ..= " [DEV]"
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
