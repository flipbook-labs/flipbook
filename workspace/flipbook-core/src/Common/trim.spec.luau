local JestGlobals = require("@pkg/JestGlobals")

local trim = require("./trim")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("removes surrounding whitespace", function()
	expect(trim(" \tFlipbook\n ")).toBe("Flipbook")
	expect(trim("   ")).toBe("")
	expect(trim("")).toBe("")
end)

test("preserves interior whitespace", function()
	expect(trim("Flipbook story")).toBe("Flipbook story")
end)
