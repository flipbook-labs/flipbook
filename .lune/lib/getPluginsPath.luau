local run = require("./run")

local function getPluginsPath(os: string)
	if os == "macos" then
		return run("dirname", { "$HOME/Documents/Roblox/Plugins" })
	elseif os == "windows" then
		return run("dirname", { "$LOCALAPPDATA/Roblox/Plugins" })
	end
	return nil
end

return getPluginsPath
