-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()

-- Lute's unused_variable lint doesn't count writing a property as a use.
-- lute-lint-ignore(unused_variable)
local Players = game:GetService("Players")

local FlipbookCore = require("@workspace/flipbook-core/src")
local FlipbookLogger = require("@workspace/flipbook-core/src/logger")
local enableOutputLogging = require("@workspace/flipbook-core/src/Logs/enableOutputLogging")

enableOutputLogging()
local logger = FlipbookLogger.child(script.Name)

local GET_LAUNCH_DATA_REMOTE_NAME = "GetLaunchData"

logger.info("starting...")

logger.info("disabling character auto-loading...")
Players.CharacterAutoLoads = false

-- Lute's unused_variable lint doesn't count writing a property as a use.
-- lute-lint-ignore(unused_variable)
local getLaunchDataRemote = Instance.new("RemoteFunction")
getLaunchDataRemote.Name = GET_LAUNCH_DATA_REMOTE_NAME
getLaunchDataRemote.OnServerInvoke = function(player)
	return FlipbookCore.parseLaunchData(player:GetJoinData().LaunchData)
end
getLaunchDataRemote.Parent = script.Parent

logger.info(`successfully initialized in {os.clock() - startTime}s`)
