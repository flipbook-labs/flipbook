local JestGlobals = require("@pkg/JestGlobals")
local isStoryModule = require("./isStoryModule")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return `true` for a ModuleScript with .story in the name", function()
	local module = Instance.new("ModuleScript")
	module.Name = "Foo.story"

	expect(isStoryModule(module)).toBe(true)
end)

test("return `false` if the given instance is not a ModuleScript", function()
	local folder = Instance.new("Folder")
	folder.Name = "Folder.story"

	expect(isStoryModule(folder)).toBe(false)
end)

test("return `false` if a ModuleScript does not have .story in the name", function()
	local module = Instance.new("ModuleScript")

	expect(isStoryModule(module)).toBe(false)
end)
