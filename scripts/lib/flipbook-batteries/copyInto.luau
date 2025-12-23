local fs = require("@lute/fs")

local mkdir = require("@scripts/lib/flipbook-batteries/mkdir")

local function copyInto(src: string, dest: string)
	if fs.type(src) == "dir" then
		if not fs.exists(dest) then
			mkdir(dest)
		end

		for _, file in fs.listdir(src) do
			local filePath = `{src}/{file.name}`
			local fileDest = `{dest}/{file.name}`

			if file.type == "dir" then
				copyInto(filePath, fileDest)
			else
				fs.copy(filePath, fileDest)
			end
		end
	else
		fs.copy(src, dest)
	end
end

return copyInto
