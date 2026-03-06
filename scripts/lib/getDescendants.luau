local fs = require("@std/fs")
local path = require("@std/path")

local function getDescendants(dirPath: path.pathlike): { path.path }
	local function reduce(rootPath: path.path, accumulator: { path.path }): { path.path }
		for _, child in fs.listdirectory(rootPath) do
			local childPath = path.join(rootPath, child.name)
			table.insert(accumulator, childPath)

			if child.type == "dir" then
				reduce(childPath, accumulator)
			end
		end
		return accumulator
	end

	local rootPath = path.resolve(dirPath)

	if fs.type(rootPath) ~= "dir" then
		return {}
	end

	return reduce(rootPath, {})
end

return getDescendants
