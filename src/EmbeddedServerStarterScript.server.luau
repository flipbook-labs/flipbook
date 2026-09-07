-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")

local FlipbookCore = require("@workspace/flipbook-core/src")

local LAUNCH_DATA_REMOTE_NAME = "LaunchData"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

local launchDataRemote = Instance.new("RemoteFunction")
launchDataRemote.Name = LAUNCH_DATA_REMOTE_NAME
launchDataRemote.OnServerInvoke = function(player)
	return FlipbookCore.parseLaunchData(player:GetJoinData().LaunchData)
end
launchDataRemote.Parent = script.Parent

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
