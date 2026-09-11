local fs = require("@std/fs")
local path = require("@std/path")

local getStudioPluginsPath = require("@scripts/lib/getStudioPluginsPath")
local project = require("@repo/project")

local PATHS_TO_CLEAN: { path.Pathlike } = {
	project.BUILD_PATH,
	path.join(getStudioPluginsPath(), project.PLUGIN_FILENAME),
	project.PLUGIN_FILENAME,
}

local function clean()
	for _, pathToClean in PATHS_TO_CLEAN do
		local filePath = path.resolve(pathToClean)

		if fs.exists(filePath) then
			print(`removing {filePath}`)

			if fs.type(filePath) == "dir" then
				fs.removeDirectory(filePath, {
					recursive = true,
				})
			else
				fs.remove(filePath)
			end
		end
	end
end

return clean
