return function()
	local mapRanges = require(script.Parent.mapRanges)

	it("should return 1.5 if we remap 0.5 from a 0 -> 1 range to a 1 -> 2 range", function()
		expect(mapRanges(0.5, 0, 1, 1, 2)).to.equal(1.5)
	end)

	it("should error if max0 is the same as min0", function()
		expect(mapRanges(0.5, 1, 1, 2, 2)).to.throw()
	end)
end
