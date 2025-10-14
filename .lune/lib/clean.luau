local fs = require("@lune/fs")
local project = require("@repo/project")
local roblox = require("@lune/roblox")

local function clean()
	if fs.isDir(project.BUILD_PATH) then
		fs.removeDir(project.BUILD_PATH)
	end

	local pluginPath = `{roblox.studioPluginPath()}/{project.PLUGIN_FILENAME}`
	if fs.isFile(pluginPath) then
		fs.removeFile(pluginPath)
	end

	if fs.isFile(project.PLUGIN_FILENAME) then
		fs.removeFile(project.PLUGIN_FILENAME)
	end
end

return clean
