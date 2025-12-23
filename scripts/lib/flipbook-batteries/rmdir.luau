local fs = require("@lute/fs")

local function rmdir(filePath: string)
	if not fs.exists(filePath) then
		return
	end

	if fs.type(filePath) == "dir" then
		for _, child in fs.listdir(filePath) do
			rmdir(`{filePath}/{child.name}`)
		end
		fs.rmdir(filePath)
	else
		fs.remove(filePath)
	end
end

return rmdir
