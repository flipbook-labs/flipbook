local JestGlobals = require("@pkg/JestGlobals")

local parseLaunchData = require("./parseLaunchData")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("reads supported fields from JSON launch data", function()
	expect(parseLaunchData('{"search":"RobloxProfile|SuccessDialog","story":"FlipbookCore/About/RobloxProfile"}')).toEqual({
		search = "RobloxProfile|SuccessDialog",
		story = "FlipbookCore/About/RobloxProfile",
	})
end)

test("ignores malformed or unsupported launch data", function()
	expect(parseLaunchData("not json")).toEqual({})
	expect(parseLaunchData('{"search":42,"story":false}')).toEqual({})
	expect(parseLaunchData('{"other":"value"}')).toEqual({})
end)
