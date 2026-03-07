local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local function createRojoProjectAsync(projectPath: path.pathlike, projectContent: json.value)
	fs.writestringtofile(projectPath, json.serialize(projectContent, true))
end

return createRojoProjectAsync
