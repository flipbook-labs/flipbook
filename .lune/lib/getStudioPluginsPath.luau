local process = require("@lute/process")
local system = require("@lute/system")

local function getStudioPluginPath()
	if system.os == "macos" then
		return `{process.homedir()}/Library/Application Support/Roblox/Plugins`
	else
		return `{process.homedir()}/AppData/Local/Roblox/Plugins`
	end
end

return getStudioPluginPath
