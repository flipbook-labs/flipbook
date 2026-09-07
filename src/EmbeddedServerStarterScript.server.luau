-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")

local LAUNCH_DATA_ATTRIBUTE = "FlipbookLaunchData"
local LAUNCH_DATA_READY_ATTRIBUTE = "FlipbookLaunchDataReady"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

-- Live clients do not receive LaunchData from LocalPlayer:GetJoinData(), so
-- relay the raw value once and leave validation to the client.
local function initializeLaunchData(player: Player)
	player:SetAttribute(LAUNCH_DATA_ATTRIBUTE, player:GetJoinData().LaunchData)
	player:SetAttribute(LAUNCH_DATA_READY_ATTRIBUTE, true)
end

Players.PlayerAdded:Connect(initializeLaunchData)
for _, player in Players:GetPlayers() do
	initializeLaunchData(player)
end

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
