local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local function createRojoProjectAsync(projectPath: path.Pathlike, projectContent: json.Value): path.Path
	local resolvedProjectPath = path.resolve(projectPath)
	fs.writeStringToFile(resolvedProjectPath, json.serialize(projectContent, true))
	return resolvedProjectPath
end

return createRojoProjectAsync
