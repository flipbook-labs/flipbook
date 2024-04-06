local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.Dev.JestGlobals)
local mapRanges = require(script.Parent.mapRanges)

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return 1.5 if we remap 0.5 from a 0 -> 1 range to a 1 -> 2 range", function()
	expect(mapRanges(0.5, 0, 1, 1, 2)).to.equal(1.5)
end)

test("error if max0 is the same as min0", function()
	expect(function()
		mapRanges(0.5, 1, 1, 2, 2)
	end).to.throw()
end)
