-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")

local getLaunchData = require("@workspace/flipbook-core/src/Embedding/getLaunchData")

local LAUNCH_DATA_REMOTE_NAME = "LaunchData"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

local launchDataRemote = Instance.new("RemoteEvent")
launchDataRemote.Name = LAUNCH_DATA_REMOTE_NAME
launchDataRemote.Parent = script.Parent

local launchDataSent: { [Player]: boolean } = {}

launchDataRemote.OnServerEvent:Connect(function(player)
	if launchDataSent[player] then
		return
	end

	launchDataSent[player] = true
	launchDataRemote:FireClient(player, getLaunchData(player:GetJoinData().LaunchData))
end)

Players.PlayerRemoving:Connect(function(player)
	launchDataSent[player] = nil
end)

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
