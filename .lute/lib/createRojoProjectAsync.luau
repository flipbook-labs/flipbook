local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local function createRojoProjectAsync(projectPath: path.pathlike, projectContent: json.value): path.path
	local resolvedProjectPath = path.resolve(projectPath)
	fs.writestringtofile(resolvedProjectPath, json.serialize(projectContent, true))
	return resolvedProjectPath
end

return createRojoProjectAsync
