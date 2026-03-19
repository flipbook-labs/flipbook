local process = require("@std/process")
local system = require("@std/system")

local function getStudioPluginPath()
	if system.os == "Darwin" then
		return `{process.homedir()}/Documents/Roblox/Plugins`
	else
		return `{process.homedir()}/AppData/Local/Roblox/Plugins`
	end
end

return getStudioPluginPath
