local fs = require("@lute/fs")

local function findAndReplace(filePath: string, match: string, replacement: string)
	-- FIXME: Need to figure out which HandleMode to use still. Currently
	-- findAndReplace is deleting the contents of the React linker modules,
	-- which breaks the build
	local handle = fs.open(filePath, "w+")
	local content = fs.read(handle)

	content = content:gsub(match, replacement)

	fs.write(handle, content)
	fs.close(handle)
end

return findAndReplace
