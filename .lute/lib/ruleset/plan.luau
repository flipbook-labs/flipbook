local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")
local process = require("@std/process")
local system = require("@std/system")

local function writeTemporaryJson(name: string, value: any): path.Path
	local filePath = path.join(system.tmpdir(), `flipbook-ruleset-{name}-{math.random(0, 0xffffff)}.json`)
	fs.writeStringToFile(filePath, json.serialize(value, true) .. "\n")
	return filePath
end

local function show(desired: any, live: any): boolean
	if json.serialize(desired) == json.serialize(live) then
		print("Ruleset is in sync.")
		return false
	end

	local livePath = writeTemporaryJson("live", live)
	local desiredPath = writeTemporaryJson("desired", desired)
	print("Ruleset drift detected:")
	process.run({ "git", "diff", "--no-index", "--", tostring(livePath), tostring(desiredPath) }, {
		stdio = "inherit",
	})
	fs.remove(livePath)
	fs.remove(desiredPath)
	return true
end

return {
	show = show,
	writeTemporaryJson = writeTemporaryJson,
}
