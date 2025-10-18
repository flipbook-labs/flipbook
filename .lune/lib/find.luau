local fs = require("@lune/fs")

local function find(root: string, pattern: string): { string }
	local matches: { string } = {}

	local function search(path: string)
		if fs.isDir(path) then
			for _, child in fs.readDir(path) do
				local childPath = `{path}/{child}`
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
