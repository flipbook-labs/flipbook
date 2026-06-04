-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local Players = game:GetService("Players")

Players.CharacterAutoLoads = false
