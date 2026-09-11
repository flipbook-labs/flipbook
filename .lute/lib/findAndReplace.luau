local fs = require("@std/fs")
local path = require("@std/path")

local function findAndReplace(filePath: path.Pathlike, match: string, replacement: string)
	local content = fs.readFileToString(filePath)

	content = content:gsub(match, replacement)

	fs.writeStringToFile(filePath, content)
end

return findAndReplace
