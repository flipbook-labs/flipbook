local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local FlipbookCore = require("@workspace/flipbook-core/src")

local PLUGIN_NAME = "Flipbook" .. if _G.BUILD_CHANNEL == "development" then ` [{_G.BUILD_HASH}]` else ""

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)

local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true)

local widget = plugin:CreateDockWidgetPluginGui(PLUGIN_NAME, info)
widget.Name = PLUGIN_NAME
widget.Title = PLUGIN_NAME
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local button = toolbar:CreateButton(PLUGIN_NAME, "Open story view", FlipbookCore.FLIPBOOK_LOGO)

local flipbookPlugin = FlipbookCore.createFlipbookPlugin(plugin, widget, button)

plugin.Unloading:Connect(flipbookPlugin.destroy)
