local constants = require("./constants")
local getPluginsPath = require("./getPluginsPath")
local process = require("@lune/process")
local run = require("./run")

local function clean()
	local pluginPath = getPluginsPath(process.os)

	run("rm", { "-rf", `{constants.BUILD_PATH}` })
	run("rm", { "-rf", `{pluginPath}/{constants.PLUGIN_FILENAME}` })
	run("rm", { "-rf", `{constants.PLUGIN_FILENAME}` })
end

return clean
