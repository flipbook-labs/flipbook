local getStudioPluginsPath = require("@scripts/lib/getStudioPluginsPath")
local project = require("@repo/project")
local run = require("@scripts/lib/run")

local function clean()
	run("rm", { "-rf", `{project.BUILD_PATH}` })
	run("rm", { "-rf", `{getStudioPluginsPath()}/{project.PLUGIN_FILENAME}` })
	run("rm", { "-rf", `{project.PLUGIN_FILENAME}` })
end

return clean
