local run = require("./run")

local function getPluginsPath(os: string): string?
	if os == "macos" then
		return run("realpath", { "$HOME/Documents/Roblox/Plugins" })
	elseif os == "windows" then
		return run("realpath", { "$LOCALAPPDATA/Roblox/Plugins" })
	end
	return nil
end

return getPluginsPath
