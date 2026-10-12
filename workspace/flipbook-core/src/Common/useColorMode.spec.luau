local JestGlobals = require("@pkg/JestGlobals")

local renderHook = require("@root/Testing/renderHook")

local useColorMode = require("./useColorMode")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("gets the current color mode", function()
	local getColorMode = renderHook(function()
		return useColorMode()
	end)

	expect(getColorMode()).toBe("Light")
end)
