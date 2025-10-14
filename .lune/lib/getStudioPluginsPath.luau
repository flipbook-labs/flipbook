local process = require("@lute/process")
local system = require("@lute/system")

local function getStudioPluginPath()
	print("OS", system.os)
	if system.os == "Darwin" then
		return `{process.homedir()}/Documents/Roblox/Plugins`
	else
		return `{process.homedir()}/AppData/Local/Roblox/Plugins`
	end
end

return getStudioPluginPath
