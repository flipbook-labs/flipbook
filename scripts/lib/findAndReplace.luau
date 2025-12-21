local fs = require("@lute/fs")

local function findAndReplace(filePath: string, match: string, replacement: string)
	local handle = fs.open(filePath, "w+")
	local content = fs.read(handle)

	content = content:gsub(match, replacement)

	fs.write(handle, content)
	fs.close(handle)
end

return findAndReplace
