local JestGlobals = require("@pkg/JestGlobals")

local computeDraggedSizes = require("@root/computeDraggedSizes")

local expect = JestGlobals.expect
local test = JestGlobals.test
local describe = JestGlobals.describe

describe("computeDraggedSizes", function()
	test("normal drag increases before and decreases after", function()
		local newBefore, newAfter = computeDraggedSizes(1000, 50, 50, 50, nil, nil)
		expect(newBefore).toBeCloseTo(55, 1)
		expect(newAfter).toBeCloseTo(45, 1)
		expect(newBefore + newAfter).toBeCloseTo(100, 5)
	end)

	test("drag in negative direction shrinks before", function()
		local newBefore, newAfter = computeDraggedSizes(1000, -100, 50, 50, nil, nil)
		expect(newBefore).toBeCloseTo(40, 1)
		expect(newAfter).toBeCloseTo(60, 1)
	end)

	test("clamps before panel at min", function()
		-- before is 200px out of 1000px = 20 ratio. drag -300px would go below min=100px
		local newBefore, newAfter = computeDraggedSizes(1000, -300, 20, 80, NumberRange.new(100, math.huge), nil)
		expect(newBefore).toBeCloseTo(10, 1)
		expect(newAfter).toBeCloseTo(90, 1)
	end)

	test("clamps before panel at max", function()
		-- before is 400px out of 1000px = 40 ratio. drag +400px would exceed max=600px
		local newBefore, newAfter = computeDraggedSizes(1000, 400, 40, 60, NumberRange.new(0, 600), nil)
		expect(newBefore).toBeCloseTo(60, 1)
		expect(newAfter).toBeCloseTo(40, 1)
	end)

	test("clamps by after panel min (before cannot take space below afterMin)", function()
		-- after min is 300px, available=1000, before=70, after=30 (300px); dragging +100 would push after below 300px
		local newBefore, newAfter = computeDraggedSizes(1000, 100, 70, 30, nil, NumberRange.new(300, math.huge))
		expect(newAfter).toBeCloseTo(30, 1)
		expect(newBefore).toBeCloseTo(70, 1)
	end)

	test("total weight is always preserved", function()
		type Case = { number | NumberRange | nil }
		local cases: { Case } = {
			{ 1000, 999, 50, 50, nil, nil },
			{ 1000, -999, 50, 50, nil, nil },
			{ 500, 50, 30, 70, NumberRange.new(50, 400), NumberRange.new(50, 400) },
		}
		for _, c in cases do
			local c1, c2, c3, c4, c5, c6 =
				c[1] :: number,
				c[2] :: number,
				c[3] :: number,
				c[4] :: number,
				c[5] :: NumberRange?,
				c[6] :: NumberRange?
			local newBefore, newAfter = computeDraggedSizes(c1, c2, c3, c4, c5, c6)
			expect(newBefore + newAfter).toBeCloseTo(c3 + c4, 5)
		end
	end)

	test("returns unchanged ratios when availablePx is zero", function()
		local newBefore, newAfter = computeDraggedSizes(0, 100, 50, 50, nil, nil)
		expect(newBefore).toBe(50)
		expect(newAfter).toBe(50)
	end)
end)
