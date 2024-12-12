local JestGlobals = require("@pkg/JestGlobals")
local createTreeNodesFromPartials = require("./createTreeNodesFromPartials")
local types = require("./types")

local expect = JestGlobals.expect
local test = JestGlobals.test

type PartialTreeNode = types.PartialTreeNode

test("top-level nodes with no children", function()
	local partials: { PartialTreeNode } = {
		{
			label = "Node 1",
		},
		{
			label = "Node 2",
		},
		{
			label = "Node 3",
		},
	}

	expect(createTreeNodesFromPartials(partials)).toEqual({
		{
			label = "Node 1",
			icon = "none",
			isExpanded = false,
			children = {},
		},
		{
			label = "Node 2",
			icon = "none",
			isExpanded = false,
			children = {},
		},
		{
			label = "Node 3",
			icon = "none",
			isExpanded = false,
			children = {},
		},
	})
end)

test("nodes with children", function()
	local partials: { PartialTreeNode } = {
		{
			label = "Node 1",
			children = {
				{
					label = "Child A 1",
					children = {
						{
							label = "Child B 1",
						},
					},
				} :: PartialTreeNode,
				{
					label = "Child A 2",
				} :: PartialTreeNode,
			},
		},
		{
			label = "Node 2",
		},
	}

	expect(createTreeNodesFromPartials(partials)).toEqual({
		{
			label = "Node 1",
			icon = "none",
			isExpanded = false,
			children = {
				{
					label = "Child A 1",
					parent = expect.anything(),
					icon = "none",
					isExpanded = false,
					children = {
						{
							label = "Child B 1",
							parent = expect.anything(),
							icon = "none",
							isExpanded = false,
							children = {},
						},
					},
				},
				{
					label = "Child A 2",
					parent = expect.anything(),
					icon = "none",
					isExpanded = false,
					children = {},
				},
			},
		},
		{
			label = "Node 2",
			icon = "none",
			isExpanded = false,
			children = {},
		},
	})
end)
