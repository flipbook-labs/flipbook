local JestGlobals = require("@pkg/JestGlobals")

local renderHook = require("@root/Testing/renderHook")

local useThemeName = require("./useThemeName")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("gets the current theme", function()
	local getThemeName = renderHook(function()
		return useThemeName()
	end)

	expect(getThemeName()).toBe("Dark")
end)
