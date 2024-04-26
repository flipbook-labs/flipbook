local constants = require("./constants")
local run = require("./run")

local function clean()
	run("rm", { "-rf", `{constants.BUILD_PATH}` })
	-- run("rm", { "-rf", `{constants.PLUGIN_PATH}` })
	run("rm", { "-rf", `{constants.PLUGIN_FILENAME}` })
end

return clean
