local JestGlobals = require("@pkg/JestGlobals")
local constants = require("@root/constants")
local isStoryModule = require("./isStoryModule")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return `true` for a ModuleScript with .story in the name", function()
	local module = Instance.new("ModuleScript")
	module.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "Foo.stories" else "Foo.story"

	expect(isStoryModule(module)).toBe(true)
end)

test("return `false` if the given instance is not a ModuleScript", function()
	local folder = Instance.new("Folder")
	folder.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "Folder.stories" else "Folder.story"

	expect(isStoryModule(folder)).toBe(false)
end)

test("return `false` if a ModuleScript does not have .story in the name", function()
	local module = Instance.new("ModuleScript")

	expect(isStoryModule(module)).toBe(false)
end)
