local fs = require("@lune/fs")

local function getWatchedFiles(filePatterns: { string }): { string }
	local files = {}

	local function traverse(rootDir: string, filePattern: string)
		for _, file in fs.readDir(rootDir) do
			local filePath = `{rootDir}/{file}`
			if fs.isDir(filePath) then
				traverse(filePath, filePattern)
			else
				if filePath:match(filePattern) then
					table.insert(files, filePath)
				end
			end
		end
	end

	for _, filePattern in filePatterns do
		local rootDir = filePattern:split("/")[1]

		assert(
			rootDir and fs.isDir(rootDir),
			`first part of file pattern must be a directory ({rootDir} is not a directory)`
		)

		traverse(rootDir, filePattern)
	end

	return files
end

return getWatchedFiles
