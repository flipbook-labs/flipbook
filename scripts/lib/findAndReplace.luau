local fs = require("@lute/fs")

local function findAndReplace(filePath: string, match: string, replacement: string)
	local readHandle = fs.open(filePath, "r")
	local content = fs.read(readHandle)
	fs.close(readHandle)

	content = content:gsub(match, replacement)

	local writeHandle = fs.open(filePath, "w")
	fs.write(writeHandle, content)
	fs.close(writeHandle)
end

return findAndReplace
