local fs = require("@std/fs")
local path = require("@std/path")

local function findAndReplace(filePath: path.pathlike, match: string, replacement: string)
	local content = fs.readfiletostring(filePath)

	content = content:gsub(match, replacement)

	fs.writestringtofile(filePath, content)
end

return findAndReplace
