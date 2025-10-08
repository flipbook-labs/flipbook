local project = require("@repo/project")
local roblox = require("@lune/roblox")

local run = require("./run")

local function clean()
	run("rm", { "-rf", `{project.BUILD_PATH}` })
	run("rm", { "-rf", `{roblox.studioPluginPath()}/{project.PLUGIN_FILENAME}` })
	run("rm", { "-rf", `{project.PLUGIN_FILENAME}` })
end

return clean
