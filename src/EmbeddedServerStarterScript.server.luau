-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")
local getLaunchData = require("@workspace/flipbook-core/src/Embedding/getLaunchData")

local SEARCH_TERM_ATTRIBUTE = "FlipbookSearchTerm"
local STORY_PATH_ATTRIBUTE = "FlipbookStoryPath"
local LAUNCH_DATA_READY_ATTRIBUTE = "FlipbookLaunchDataReady"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

local function initializeLaunchData(player: Player)
	local launchData = getLaunchData(player:GetJoinData().LaunchData)
	if launchData.search then
		player:SetAttribute(SEARCH_TERM_ATTRIBUTE, launchData.search)
	end
	if launchData.story then
		player:SetAttribute(STORY_PATH_ATTRIBUTE, launchData.story)
	end
	player:SetAttribute(LAUNCH_DATA_READY_ATTRIBUTE, true)
end

Players.PlayerAdded:Connect(initializeLaunchData)
for _, player in Players:GetPlayers() do
	initializeLaunchData(player)
end

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
