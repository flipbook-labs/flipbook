local RunService = game:GetService("RunService")

if RunService:IsRunning() or not RunService:IsEdit() then
	return
end

local createFlipbookPlugin = require("@root/Plugin/createFlipbookPlugin")

local PLUGIN_NAME = "flipbook"

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local flipbookPlugin = createFlipbookPlugin(PLUGIN_NAME, plugin, toolbar)

plugin.Unloading:Connect(flipbookPlugin.unmount)
