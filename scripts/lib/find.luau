local fs = require("@lute/fs")

local function find(root: string, pattern: string): { string }
	local matches: { string } = {}

	if not fs.exists(root) or fs.type(root) == "file" then
		return matches
	end

	local function search(path: string)
		if fs.type(path) == "dir" then
			for _, child in fs.listdir(path) do
				local childPath = `{path}/{child.name}`
				search(childPath)
			end
		else
			if path:match(pattern) then
				table.insert(matches, path)
			end
		end
	end

	search(root)

	return matches
end

return find
