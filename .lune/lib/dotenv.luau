local fs = require("@lune/fs")
local process = require("@lune/process")

local DOTENV_FILE_NAME = ".env"

local function dotenv()
	local current = process.cwd
	local env: { [string]: string | number | boolean } = {}

	for _, file in fs.readDir(current) do
		local filePath = `{current}/{file}`
		if file == DOTENV_FILE_NAME then
			local content = fs.readFile(filePath)

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
