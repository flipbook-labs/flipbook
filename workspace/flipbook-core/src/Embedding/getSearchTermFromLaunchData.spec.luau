local JestGlobals = require("@pkg/JestGlobals")

local getSearchTermFromLaunchData = require("./getSearchTermFromLaunchData")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("reads the search field from JSON launch data", function()
	expect(getSearchTermFromLaunchData('{"search":"RobloxProfile|SuccessDialog"}')).toBe("RobloxProfile|SuccessDialog")
end)

test("ignores malformed or unsupported launch data", function()
	expect(getSearchTermFromLaunchData("not json")).toBe(nil)
	expect(getSearchTermFromLaunchData('{"search":42}')).toBe(nil)
	expect(getSearchTermFromLaunchData('{"other":"value"}')).toBe(nil)
end)
