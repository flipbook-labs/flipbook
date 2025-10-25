local JestGlobals = require("@pkg/JestGlobals")
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local createTreeNodeStore = require("./createTreeNodeStore")

test("nodes can be parented to each other", function()
	local parent = createTreeNodeStore()
	local child = createTreeNodeStore()

	child.parentTo(parent)

	expect(child.getParent(false)).toBe(parent)
	expect(parent.getChildren(false)).toMatchObject({ child })

	child.parentTo(nil)

	expect(child.getParent(false)).toBeUndefined()
	expect(parent.getChildren(false)).never.toMatchObject({ child })
end)

test("nodes can be named", function()
	local root = createTreeNodeStore()
	expect(root.getName(false)).toBe("Node")

	root.setName("<root>")
	expect(root.getName(false)).toBe("<root>")
end)

describe("hierarchy", function()
	test("descendants are tracked in ancestor nodes", function()
		local root = createTreeNodeStore()

		local child = createTreeNodeStore()
		child.parentTo(root)

		local descendant = createTreeNodeStore()
		descendant.parentTo(child)

		expect(root.getDescendants(false)).toEqual(expect.arrayContaining({ child, descendant }))
		expect(child.getDescendants(false)).toEqual({ descendant })
		expect(descendant.getDescendants(false)).toEqual({})
	end)

	test("ancestors are tracked in descendant nodes", function()
		local root = createTreeNodeStore()

		local child = createTreeNodeStore()
		child.parentTo(root)

		local descendant = createTreeNodeStore()
		descendant.parentTo(child)

		expect(root.getAncestors(false)).toEqual({})
		expect(child.getAncestors(false)).toEqual({ root })
		expect(descendant.getAncestors(false)).toEqual(expect.arrayContaining({ child, root }))
	end)

	test("parenting a node to nil removes it from the hierarchy", function()
		local root = createTreeNodeStore()

		local childA = createTreeNodeStore()
		childA.parentTo(root)

		local childADescendant = createTreeNodeStore()
		childADescendant.parentTo(childA)

		local childB = createTreeNodeStore()
		childB.parentTo(root)

		expect(root.getChildren(false)).toEqual(expect.arrayContaining({ childA, childB }))
		expect(root.getDescendants(false)).toEqual(expect.arrayContaining({ childA, childADescendant, childB }))

		childA.parentTo(nil)

		expect(root.getChildren(false)).toEqual({ childB })
		expect(root.getDescendants(false)).toEqual({ childB })
	end)
end)

describe("expand and collapse nodes", function()
	test("calling expandDown on an ancestor node will expand all descendants", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local descendant3 = createTreeNodeStore()
		descendant3.parentTo(descendant2)

		local descendant4 = createTreeNodeStore()
		descendant4.parentTo(descendant3)

		root.expandDown()

		for _, node in { root, descendant1, descendant2, descendant3, descendant4 } do
			expect(node.getIsExpanded(false)).toBe(true)
		end
	end)

	test("calling expandUp on a descendant node will expand all ancestors", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local descendant3 = createTreeNodeStore()
		descendant3.parentTo(descendant2)

		local descendant4 = createTreeNodeStore()
		descendant4.parentTo(descendant3)

		descendant2.expandUp()

		expect(root.getIsExpanded(false)).toBe(true)
		expect(descendant1.getIsExpanded(false)).toBe(true)
		expect(descendant2.getIsExpanded(false)).toBe(true)
		expect(descendant3.getIsExpanded(false)).toBe(false)
		expect(descendant4.getIsExpanded(false)).toBe(false)
	end)

	test("calling collapseDown on an ancestor node will collapse all descendants", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local descendant3 = createTreeNodeStore()
		descendant3.parentTo(descendant2)

		local descendant4 = createTreeNodeStore()
		descendant4.parentTo(descendant3)

		-- Expand everything so we can compare how collapsing works
		root.expandDown()

		descendant2.collapseDown()

		expect(root.getIsExpanded(false)).toBe(true)
		expect(descendant1.getIsExpanded(false)).toBe(true)
		expect(descendant2.getIsExpanded(false)).toBe(false)
		expect(descendant3.getIsExpanded(false)).toBe(false)
		expect(descendant4.getIsExpanded(false)).toBe(false)
	end)
end)
