local fs = require("@std/fs")
local path = require("@std/path")

local function reduce(rootPath: path.Path, accumulator: { path.Path }): { path.Path }
	for _, child in fs.listDirectory(rootPath) do
		local childPath = path.join(rootPath, child.name)
		table.insert(accumulator, childPath)

		if child.type == "dir" then
			reduce(childPath, accumulator)
		end
	end
	return accumulator
end

local function getDescendants(dirPath: path.Pathlike): { path.Path }
	local rootPath = path.resolve(dirPath)

	if fs.type(rootPath) ~= "dir" then
		return {}
	end

	return reduce(rootPath, {})
end

return getDescendants
