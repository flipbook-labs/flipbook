local fs = require("@lute/fs")
local process = require("@lute/process")

local DOTENV_FILE_NAME = ".env"

local function dotenv()
	local current = process.cwd()
	local env: { [string]: string } = {}

	for _, file in fs.listdir(current) do
		local filePath = `{current}/{file.name}`
		if file.name == DOTENV_FILE_NAME then
			local handle = fs.open(filePath, "r")
			local content = fs.read(handle)
			fs.close(handle)

			for line in content:gmatch("[^\r\n]+") do
				local key, value = line:match("([%u_]+)[%s+]?=[%s+]?(.*)")

				if key and value and value ~= "" then
					value = value:gsub('"', "")
					env[key] = value
				end
			end
		end
	end

	for key, value in env do
		process.env[key] = value
	end
end

return dotenv
