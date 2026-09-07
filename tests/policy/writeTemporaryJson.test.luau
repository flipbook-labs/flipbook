local fs = require("@std/fs")
local json = require("@std/json")
local system = require("@std/system")
local test = require("@std/test")

local writeTemporaryJson = require("@scripts/lib/policy/writeTemporaryJson")

test.case("writes formatted JSON to the selected temporary directory", function(assert)
	local filePath = writeTemporaryJson("test", { enabled = true }, system.tmpdir())
	local contents = fs.readFileToString(filePath)

	assert.eq((json.deserialize(contents) :: any).enabled, true)
	assert.that(contents:sub(-1) == "\n")
	fs.remove(filePath)
end)
