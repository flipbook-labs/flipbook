local JestGlobals = require("@pkg/JestGlobals")
local analyzeStorybook = require("./analyzeStorybook")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("ok when nothing but an empty storyRoots array", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "test.storybook.lua"
	storybook.Source = [[{
			storyRoots = {},
		}]]

	local diagnostics = analyzeStorybook(storybook)

	expect(#diagnostics).to.equal(0)
end)

test("ok when nothing but a storyRoots array with an instance inside", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "test.storybook.lua"
	storybook.Source = [[{
			storyRoots = {
				Instance.new("Folder"),
			},
		}]]

	local diagnostics = analyzeStorybook(storybook)

	expect(#diagnostics).to.equal(0)
end)

test("diagnostics for a bad storyRoots array", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "test.storybook.lua"
	storybook.Source = [[{
			storyRoots = {
				true,
				"foo",
				2,
			},
		}]]

	local diagnostics = analyzeStorybook(storybook)

	expect(#diagnostics).to.equal(1)
end)

test("diagnostics for a bad storyRoots value", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "test.storybook.lua"
	storybook.Source = [[{
			storyRoots = {
				true,
				"foo",
				2,
			},
		}]]

	local diagnostics = analyzeStorybook(storybook)

	expect(#diagnostics).to.equal(1)
end)
