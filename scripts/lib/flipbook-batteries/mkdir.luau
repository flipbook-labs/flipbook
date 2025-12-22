local fs = require("@lute/fs")
local process = require("@lute/process")

local function startsWith(str: string, prefix: string)
	return str:sub(1, #prefix) == prefix
end

local function mkdir(dirPath: string)
	dirPath = dirPath:gsub("/+", "/")

	local current = if startsWith(dirPath, "/") then "/" else process.cwd()

	for _, dir in dirPath:split("/") do
		if dir == "" then
			continue
		end

		if current then
			current ..= `{dir}/`
		else
			current = dir
		end

		if not fs.exists(current) then
			fs.mkdir(current)
		end
	end
end

return mkdir
