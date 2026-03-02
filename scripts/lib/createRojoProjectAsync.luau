local fs = require("@lute/fs")
local json = require("@std/json")

local function createRojoProjectAsync(projectPath: string, projectContent: json.value)
	local handle = fs.open(projectPath, "w+")
	fs.write(handle, json.serialize(projectContent, true))
	fs.close(handle)
end

return createRojoProjectAsync
