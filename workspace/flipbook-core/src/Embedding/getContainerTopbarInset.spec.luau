local JestGlobals = require("@pkg/JestGlobals")

local getContainerTopbarInset = require("./getContainerTopbarInset")

local expect = JestGlobals.expect
local test = JestGlobals.test

local TOPBAR_INSET = Rect.new(Vector2.new(120, 0), Vector2.new(900, 58))

test("matches the topbar inset for a container at the top of the screen", function()
	local inset = getContainerTopbarInset(TOPBAR_INSET, Vector2.new(0, -58), Vector2.new(0, 58))

	expect(inset.Min).toEqual(Vector2.new(120, 0))
	expect(inset.Max).toEqual(Vector2.new(900, 58))
end)

test("adds the GUI inset back to the container position", function()
	local inset = getContainerTopbarInset(TOPBAR_INSET, Vector2.zero, Vector2.new(0, 58))

	expect(inset.Min).toEqual(Vector2.new(120, -58))
	expect(inset.Max).toEqual(Vector2.new(900, 0))
end)

test("shifts the inset by the container's offset", function()
	local inset = getContainerTopbarInset(TOPBAR_INSET, Vector2.new(40, -48), Vector2.new(0, 58))

	expect(inset.Min).toEqual(Vector2.new(80, -10))
	expect(inset.Max).toEqual(Vector2.new(860, 48))
end)
