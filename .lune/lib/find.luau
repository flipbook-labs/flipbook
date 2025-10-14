local fs = require("@lute/fs")

local function find(root: string, pattern: string): { string }
	local matches: { string } = {}

	local function search(path: string)
		if fs.exists(path) then
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
