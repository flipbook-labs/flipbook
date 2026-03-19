local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local function getStudioPluginPath(): path.path
	if system.os == "Darwin" then
		return path.join(process.homedir(), "Documents/Roblox/Plugins")
	else
		return path.join(process.homedir(), "AppData/Local/Roblox/Plugins")
	end
end

return getStudioPluginPath
