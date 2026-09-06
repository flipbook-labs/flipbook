-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()
local prefix = `[{script.Name}]`

local Players = game:GetService("Players")
local getSearchTermFromLaunchData = require("@workspace/flipbook-core/src/Embedding/getSearchTermFromLaunchData")

local SEARCH_TERM_ATTRIBUTE = "FlipbookSearchTerm"
local SEARCH_TERM_READY_ATTRIBUTE = "FlipbookSearchTermReady"

print(`{prefix} starting...`)

print(`{prefix} disabling character auto-loading...`)
Players.CharacterAutoLoads = false

local function initializeSearchTerm(player: Player)
	local searchTerm = getSearchTermFromLaunchData(player:GetJoinData().LaunchData)
	if searchTerm then
		player:SetAttribute(SEARCH_TERM_ATTRIBUTE, searchTerm)
	end
	player:SetAttribute(SEARCH_TERM_READY_ATTRIBUTE, true)
end

Players.PlayerAdded:Connect(initializeSearchTerm)
for _, player in Players:GetPlayers() do
	initializeSearchTerm(player)
end

print(`{prefix} successfully initialized in {os.clock() - startTime}s`)
