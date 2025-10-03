local fs = require("@lune/fs")

type Matcher = string | (path: string) -> boolean

local function find(root: string, matcher: Matcher): { string }
	local matches: { string } = {}

	local function search(path: string)
		if fs.isDir(path) then
			for _, child in fs.readDir(path) do
				local childPath = `{path}/{child}`
				search(childPath)
			end
		else
			if typeof(matcher) == "string" then
				if path:match(matcher) then
					table.insert(matches, path)
				end
			else
				if matcher(path) then
					table.insert(matches, path)
				end
			end
		end
	end

	search(root)

	return matches
end

return find
