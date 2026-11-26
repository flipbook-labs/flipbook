-- Exit immediately if this script isn't running in an embedded context.
local PluginDebugService: PluginDebugService? = game:FindService("PluginDebugService")
if PluginDebugService and PluginDebugService:IsAncestorOf(script) then
	return
end

local startTime = os.clock()

-- Lute's unused_variable lint doesn't count writing a property as a use.
-- lute-lint-ignore(unused_variable)
local Players = game:GetService("Players")

local Archivist = require("@pkg/Archivist")
local FlipbookCore = require("@workspace/flipbook-core/src")

--[[
	These lines confirm in Output that the embedded app started. The plugin's
	logger writes to Output only when the build sets `ENABLE_OUTPUT_LOGGING`, so
	these scripts use their own logger with Archivist's default console sink. Its
	level is fixed at Info so the lines show whatever `LOG_LEVEL` the build used.
]]
local logger = Archivist.createLogger(script.Name, {
	level = "Info",
	middleware = {
		Archivist.middleware.name,
	},
})

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
