local project = require("@repo/project")

local getStudioPluginsPath = require("./getStudioPluginsPath")
local run = require("./run")

local function clean()
	run("rm", { "-rf", `{project.BUILD_PATH}` })
	run("rm", { "-rf", `{getStudioPluginsPath()}/{project.PLUGIN_FILENAME}` })
	run("rm", { "-rf", `{project.PLUGIN_FILENAME}` })
end

return clean
