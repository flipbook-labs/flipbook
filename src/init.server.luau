local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

if _G.BUILD_CHANNEL == "development" then
	_G.__DEV__ = true
end

local Charm = require("@pkg/Charm")
local FlipbookCore = require("@workspace/flipbook-core/src")

local PLUGIN_NAME = "Flipbook" .. if _G.BUILD_CHANNEL == "development" then ` [{_G.BUILD_HASH}]` else ""

--[[
	Normally we want this to be `true` but there is a really nasty bug in
	Storyteller that is causing story previewing to crash. Relating to "attempt
	to modify a readonly table"

	This means Storyteller is doing something it shouldn't that is violating
	immutability, _but_ everything seems to work fine in practice, so we're
	accepting the tradeoff of having Flipbook work in the shortterm while the
	evil state bug will lurk in the shadows until it reveals itself (or we
	remove this line, whichever comes first)

	Track the issue here:

	https://github.com/flipbook-labs/storyteller/issues/100
]]
Charm.flags.frozen = false

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)

local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Top, true)

-- selene: allow(deprecated)
local widget = plugin:CreateDockWidgetPluginGuiAsync(PLUGIN_NAME, info)
widget.Name = PLUGIN_NAME
widget.Title = PLUGIN_NAME
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local button = toolbar:CreateButton(PLUGIN_NAME, "Open story view", FlipbookCore.FLIPBOOK_LOGO)

local flipbookPlugin = FlipbookCore.createFlipbookPlugin(plugin, widget, button)

plugin.Unloading:Connect(flipbookPlugin.destroy)
