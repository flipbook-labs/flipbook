local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.JestGlobals)
local types = require(flipbook.Explorer.types)
local filterComponentTreeNode = require(script.Parent.filterComponentTreeNode)

local expect = JestGlobals.expect
local test = JestGlobals.test

test("return true when the query does not match the story name", function()
	local target: types.ComponentTreeNode = {
		children = {},
		name = "test",
		icon = "story",
	}
	local query = "other"

	local result = filterComponentTreeNode(target, query)
	expect(result).toBe(true)
end)

test("return false the query matches the story name", function()
	local target: types.ComponentTreeNode = {
		children = {},
		name = "test",
		icon = "story",
	}
	local query = "tes"

	local result = filterComponentTreeNode(target, query)
	expect(result).toBe(false)
end)

test("return true when the filter does not match any of node in tree", function()
	local target: types.ComponentTreeNode = {
		children = {
			{
				children = {},
				name = "test",
				icon = "story",
			},
			{
				children = {},
				name = "folder",
				icon = "folder",
			},
		},
		name = "storybook",
		icon = "storybook",
	}
	local query = "other"

	local result = filterComponentTreeNode(target, query)
	expect(result).toBe(true)
end)

test("return false when a filter match at least one of nodes in tree", function()
	local target: types.ComponentTreeNode = {
		children = {
			{
				children = {},
				name = "test",
				icon = "story",
			},
			{
				children = {},
				name = "folder",
				icon = "folder",
			},
		},
		name = "storybook",
		icon = "storybook",
	}
	local query = "tes"

	local result = filterComponentTreeNode(target, query)
	expect(result).toBe(false)
end)
