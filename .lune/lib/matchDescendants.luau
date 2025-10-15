local fs = require("@lute/fs")

local function matchDescendants(rootPath: string, predicate: (path: string) -> boolean?): { string }
	assert(fs.stat(rootPath).type == "dir", "rootPath must be a directory")

	local descendants: { string } = {}

	local function search(path: string)
		local result = predicate(path)
		if result == nil then
			return
		elseif result == true then
			table.insert(descendants, path)
		end

		if fs.stat(path).type == "dir" then
			for _, child in fs.listdir(path) do
				search(`{path}/{child.name}`)
			end
		end
	end

	search(rootPath)

	return descendants
end

return matchDescendants
