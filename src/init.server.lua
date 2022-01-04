local RunService = game:GetService("RunService")

local Roact = require(script.Packages.Roact)
local createWidget = require(script.Plugin.createWidget)
local createToggleButton = require(script.Plugin.createToggleButton)
local App = require(script.Components.App)

local PLUGIN_NAME = "RoactStorybook"

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

print("Loading", PLUGIN_NAME)

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local widget = createWidget(plugin, PLUGIN_NAME)
local disconnectButton = createToggleButton(toolbar, widget)

local handle = Roact.mount(Roact.createElement(App), widget, "App")

plugin.Unloading:Connect(function()
	print("Unloading", PLUGIN_NAME)
	disconnectButton()
	Roact.unmount(handle)
end)
