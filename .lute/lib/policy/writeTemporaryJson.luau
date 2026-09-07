local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local system = require("@std/system")

local function writeTemporaryJson(name: string, value: any, directory: path.Pathlike?): path.Path
	local filePath = path.join(directory or system.tmpdir(), `flipbook-ruleset-{name}-{math.random(0, 0xffffff)}.json`)
	fs.writeStringToFile(filePath, json.serialize(value, true) .. "\n")
	return filePath
end

return writeTemporaryJson
