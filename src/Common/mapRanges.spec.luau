local JestGlobals = require("@pkg/jest-globals")
local mapRanges = require("./mapRanges")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return 1.5 if we remap 0.5 from a 0 -> 1 range to a 1 -> 2 range", function()
	expect(mapRanges(0.5, 0, 1, 1, 2)).toBe(1.5)
end)

test("error if max0 is the same as min0", function()
	expect(function()
		mapRanges(0.5, 1, 1, 2, 2)
	end).toThrow()
end)
