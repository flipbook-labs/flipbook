local findClientSettings = require("./findClientSettings")
local run = require("./run")

local function setFlags(os: string)
	local clientSettings = findClientSettings(os)
	if clientSettings then
		run("mkdir", { "-p", clientSettings })
		run("cp", { "-R", "tests/ClientAppSettings.json", clientSettings })
	end
end

return setFlags
