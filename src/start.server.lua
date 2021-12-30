local Roact = require(script.Parent.Packages.Roact)
local createWidget = require(script.Parent.Plugin.createWidget)
local createToggleButton = require(script.Parent.Plugin.createToggleButton)
local App = require(script.Parent.Components.App)

local PLUGIN_NAME = "RoactStorybook"

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
