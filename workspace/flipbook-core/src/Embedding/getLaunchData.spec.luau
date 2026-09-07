local JestGlobals = require("@pkg/JestGlobals")

local getLaunchData = require("./getLaunchData")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("reads supported fields from JSON launch data", function()
	expect(
		getLaunchData('{"search":"RobloxProfile|SuccessDialog","storyPathToOpen":"FlipbookCore/About/RobloxProfile"}')
	).toEqual({
		search = "RobloxProfile|SuccessDialog",
		storyPathToOpen = "FlipbookCore/About/RobloxProfile",
	})
end)

test("ignores malformed or unsupported launch data", function()
	expect(getLaunchData("not json")).toEqual({})
	expect(getLaunchData('{"search":42,"storyPathToOpen":false}')).toEqual({})
	expect(getLaunchData('{"other":"value"}')).toEqual({})
end)
