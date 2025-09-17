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

	local node1 = {
		id = expect.anything(),
		label = "Node 1",
		icon = "none",
		isExpanded = false,
		children = {},
	}
	local node2 = {
		id = expect.anything(),
		label = "Node 2",
		icon = "none",
		isExpanded = false,
		children = {},
	}
	local node3 = {
		id = expect.anything(),
		label = "Node 3",
		icon = "none",
		isExpanded = false,
		children = {},
	}

	local nodes = createTreeNodesFromPartials(partials)

	expect(nodes.byInstance).toEqual({})
	expect(nodes.expandedByDefault).toEqual({})
	expect(nodes.leaves).toEqual(expect.arrayContaining({ node1, node2, node3 }))
	expect(nodes.roots).toEqual(expect.arrayContaining({ node1, node2, node3 }))
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

	local childB1 = {
		id = expect.anything(),
		label = "Child B 1",
		parent = expect.anything(),
		icon = "none",
		isExpanded = false,
		children = {},
	}

	local childA1 = {
		id = expect.anything(),
		label = "Child A 1",
		parent = expect.anything(),
		icon = "none",
		isExpanded = false,
		children = {
			childB1,
		},
	}

	local childA2 = {
		id = expect.anything(),
		label = "Child A 2",
		parent = expect.anything(),
		icon = "none",
		isExpanded = false,
		children = {},
	}

	local node1 = {
		id = expect.anything(),
		label = "Node 1",
		icon = "none",
		isExpanded = false,
		children = {
			childA1,
			childA2,
		},
	}

	local node2 = {
		id = expect.anything(),
		label = "Node 2",
		icon = "none",
		isExpanded = false,
		children = {},
	}

	local nodes = createTreeNodesFromPartials(partials)

	expect(nodes.byInstance).toEqual({})
	expect(nodes.expandedByDefault).toEqual({})
	expect(nodes.leaves).toEqual(expect.arrayContaining({ childA2, childB1, node2 }))
	expect(nodes.roots).toEqual(expect.arrayContaining({ node1, node2 }))
end)
