-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")

local FlipbookCore = require("@workspace/flipbook-core/src")

local GET_LAUNCH_DATA_REMOTE_NAME = "GetLaunchData"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

local getLaunchDataRemote = Instance.new("RemoteFunction")
getLaunchDataRemote.Name = GET_LAUNCH_DATA_REMOTE_NAME
getLaunchDataRemote.OnServerInvoke = function(player)
	return FlipbookCore.parseLaunchData(player:GetJoinData().LaunchData)
end
getLaunchDataRemote.Parent = script.Parent

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
