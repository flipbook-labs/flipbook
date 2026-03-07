local fs = require("@lute/fs")

local function getDescendants(dirPath: string): { string }
	if fs.type(dirPath) ~= "dir" then
		return {}
	end

	local function reduce(rootPath: string, accumulator: { string }): { string }
		for _, child in fs.listdir(rootPath) do
			local childPath = `{rootPath}/{child.name}`
			table.insert(accumulator, childPath)

			if child.type == "dir" then
				reduce(childPath, accumulator)
			end
		end
		return accumulator
	end

	return reduce(dirPath, {})
end

return getDescendants
