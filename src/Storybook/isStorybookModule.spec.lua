local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.Dev.JestGlobals)
local isStorybookModule = require(script.Parent.isStorybookModule)

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return true for ModuleScripts with the .storybook extension", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "Foo.storybook"

	expect(isStorybookModule(storybook)).to.equal(true)
end)

test("return false for non-ModuleScript instances", function()
	local storybook = Instance.new("Folder")
	storybook.Name = "Foo.storybook"

	expect(isStorybookModule(storybook)).to.equal(false)
end)

test("return false if .storybook is not part of the name", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "Foo"

	expect(isStorybookModule(storybook)).to.equal(false)
end)

test("return false if .storybook is in the wrong place", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "Foo.storybook.extra"

	expect(isStorybookModule(storybook)).to.equal(false)
end)

test("return false for storybooks in CoreGui", function()
	local storybook = Instance.new("ModuleScript")
	storybook.Name = "Foo.storybook"
	storybook.Parent = CoreGui

	expect(isStorybookModule(storybook)).to.equal(false)

	storybook:Destroy()
end)
