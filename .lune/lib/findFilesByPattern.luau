local fs = require("@lune/fs")

local function findFilesByPattern(rootPath: string, pattern: string)
	local matches = {}

	local function search(path: string)
		for _, file in fs.readDir(path) do
			local filePath = `{path}/{file}`

			if fs.isDir(filePath) then
				search(filePath)
			else
				if filePath:match(pattern) then
					table.insert(matches, filePath)
				end
			end
		end
	end

	search(rootPath)

	return matches
end

return findFilesByPattern
