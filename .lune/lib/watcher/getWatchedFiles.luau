local fs = require("@lute/fs")

local function getWatchedFiles(filePatterns: { string }, excludedFilePatterns: { string }?): { string }
	local files = {}

	local function traverse(rootDir: string)
		for _, file in fs.listdir(rootDir) do
			local filePath = `{rootDir}/{file.name}`
			if fs.exists(filePath) then
				traverse(filePath)
			else
				if excludedFilePatterns then
					local isExcluded = false
					for _, excludedPattern in excludedFilePatterns do
						if filePath:match(excludedPattern) then
							isExcluded = true
							break
						end
					end
					if isExcluded then
						continue
					end
				end

				for _, filePattern in filePatterns do
					if filePath:match(filePattern) then
						table.insert(files, filePath)
						break
					end
				end
			end
		end
	end

	traverse(".")

	return files
end

return getWatchedFiles
