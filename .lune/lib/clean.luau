local roblox = require("@lune/roblox")

local constants = require("./constants")
local run = require("./run")

local function clean()
	run("rm", { "-rf", `{constants.BUILD_PATH}` })
	run("rm", { "-rf", `{roblox.studioPluginPath()}/{constants.PLUGIN_FILENAME}` })
	run("rm", { "-rf", `{constants.PLUGIN_FILENAME}` })
end

return clean
