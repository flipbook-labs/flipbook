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
	expect(parent.getChildren(false)).toEqual({ child })

	child.parentTo(nil)

	expect(child.getParent(false)).toBeUndefined()
	expect(parent.getChildren(false)).never.toEqual({ child })
end)

test("nodes can be named", function()
	local root = createTreeNodeStore()
	expect(root.getName(false)).toBe("Node")

	root.setName("<root>")
	expect(root.getName(false)).toBe("<root>")
end)

describe("node activation", function()
	test("activating a node with no children changes its selected state", function()
		local root = createTreeNodeStore()
		root.activate()

		expect(root.getIsSelected(false)).toBe(true)
		expect(root.getIsExpanded(false)).toBe(false)

		root.activate()

		expect(root.getIsSelected(false)).toBe(false)
		expect(root.getIsExpanded(false)).toBe(false)
	end)

	test("activating a node with children expands it", function()
		local root = createTreeNodeStore()

		local child = createTreeNodeStore()
		child.parentTo(root)

		root.activate()

		expect(root.getIsSelected(false)).toBe(false)
		expect(root.getIsExpanded(false)).toBe(true)

		root.activate()

		expect(root.getIsSelected(false)).toBe(false)
		expect(root.getIsExpanded(false)).toBe(false)
	end)
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

	test("moving a node in the hierarchy around works", function()
		local root = createTreeNodeStore()

		local childA = createTreeNodeStore()
		childA.parentTo(root)

		local childADescendant = createTreeNodeStore()
		childADescendant.parentTo(childA)

		local childB = createTreeNodeStore()
		childB.parentTo(root)

		expect(root.getChildren(false)).toEqual(expect.arrayContaining({ childA, childB }))

		childA.parentTo(childB)

		expect(root.getChildren(false)).toEqual(expect.arrayContaining({ childB }))
		expect(childB.getChildren(false)).toEqual(expect.arrayContaining({ childA }))
	end)

	test("parenting to the same parent is a no-op", function()
		local root = createTreeNodeStore()

		local child = createTreeNodeStore()
		child.parentTo(root)

		task.wait()

		-- Can't exactly test for it but under the hood this should just be
		-- doing an early exit since the parent is the same.
		child.parentTo(root)

		expect(root.getChildren(false)).toEqual({ child })
	end)

	test("match for descendants by a predicate", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local descendant3 = createTreeNodeStore()
		descendant3.setName("Match")
		descendant3.parentTo(descendant2)

		local descendant4 = createTreeNodeStore()
		descendant4.parentTo(descendant3)

		local matches = root.findFirstDescendant(function(node)
			return node.getName(false) == "Match"
		end)

		expect(matches).toEqual(descendant3)
	end)

	test("match for ancestors by a predicate", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local descendant3 = createTreeNodeStore()
		descendant3.setName("Match")
		descendant3.parentTo(descendant2)

		local descendant4 = createTreeNodeStore()
		descendant4.parentTo(descendant3)

		local matches = descendant4.findFirstAncestor(function(node)
			return node.getName(false) == "Match"
		end)

		expect(matches).toEqual(descendant3)
	end)

	test("getLeafNodes returns all nodes without children", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(descendant1)

		local leaf1 = createTreeNodeStore()
		leaf1.parentTo(descendant2)

		local leaf2 = createTreeNodeStore()
		leaf2.parentTo(descendant1)

		expect(root.getLeafNodes(false)).toEqual({ leaf2, leaf1 })
	end)

	test("getSelectedDescendants returns all selected descendants", function()
		local root = createTreeNodeStore()

		local child = createTreeNodeStore()
		child.parentTo(root)

		local leaf1 = createTreeNodeStore()
		leaf1.parentTo(child)

		local leaf2 = createTreeNodeStore()
		leaf2.parentTo(child)

		leaf1.setIsSelected(true)

		expect(root.getSelectedDescendants(false)).toEqual({ leaf1 })

		leaf2.setIsSelected(true)

		expect(root.getSelectedDescendants(false)).toEqual({ leaf2, leaf1 })

		leaf1.setIsSelected(false)

		expect(root.getSelectedDescendants(false)).toEqual({ leaf2 })
	end)

	test("take a snapshotof the hierarchy", function()
		local root = createTreeNodeStore()

		expect(root.snapshot()).toEqual({
			id = root.id,
			name = "Node",
			isVisible = true,
			isSelected = false,
			children = {},
		})

		local currentNode = root
		for i = 1, 3 do
			local node = createTreeNodeStore()
			node.setName(`Descendant {i}`)

			node.parentTo(currentNode)
			currentNode = node
		end

		expect(root.snapshot()).toEqual({
			id = root.id,
			name = "Node",
			isVisible = true,
			isSelected = false,
			children = expect.arrayContaining({
				expect.objectContaining({
					id = expect.anything(),
					name = "Descendant 1",
					children = expect.arrayContaining({
						expect.objectContaining({
							id = expect.anything(),
							name = "Descendant 2",
							children = expect.arrayContaining({
								expect.objectContaining({
									id = expect.anything(),
									name = "Descendant 3",
									children = {},
								}),
							}),
						}),
					}),
				}),
			}),
		})

		-- Add some more nodes to verify siblings work with the snapshot
		currentNode = root
		for i = 1, 2 do
			local node = createTreeNodeStore()
			node.setName(`Descendant {i}`)

			node.parentTo(currentNode)
			currentNode = node
		end

		expect(root.snapshot()).toEqual({
			id = root.id,
			name = "Node",
			isVisible = true,
			isSelected = false,
			children = expect.arrayContaining({
				expect.objectContaining({
					id = expect.anything(),
					name = "Descendant 1",
					children = expect.arrayContaining({
						expect.objectContaining({
							id = expect.anything(),
							name = "Descendant 2",
							children = expect.arrayContaining({
								expect.objectContaining({
									id = expect.anything(),
									name = "Descendant 3",
									children = {},
								}),
							}),
						}),
					}),
				}),
				expect.objectContaining({
					id = expect.anything(),
					name = "Descendant 1",
					children = expect.arrayContaining({
						expect.objectContaining({
							id = expect.anything(),
							name = "Descendant 2",
							children = {},
						}),
					}),
				}),
			}),
		})
	end)
end)

describe("node sorting", function()
	test("children are unsorted by default and just go off of parenting order", function()
		local root = createTreeNodeStore()

		local childA = createTreeNodeStore()
		childA.setName("A")

		local childB = createTreeNodeStore()
		childB.setName("B")

		local childC = createTreeNodeStore()
		childC.setName("C")

		local childD = createTreeNodeStore()
		childD.setName("D")

		childC.parentTo(root)
		childD.parentTo(root)
		childA.parentTo(root)
		childB.parentTo(root)

		expect(root.getChildren(false)).toEqual({ childC, childD, childA, childB })
	end)

	test("basic alphabetical sorting", function()
		local root = createTreeNodeStore()

		local childA = createTreeNodeStore()
		childA.setName("A")

		local childB = createTreeNodeStore()
		childB.setName("B")

		local childC = createTreeNodeStore()
		childC.setName("C")

		local childD = createTreeNodeStore()
		childD.setName("D")

		-- Parent the nodes haphazardly to illustrate how they get sorted
		childC.parentTo(root)
		childD.parentTo(root)
		childA.parentTo(root)
		childB.parentTo(root)

		expect(root.getChildren(false)).toEqual({ childC, childD, childA, childB })

		root.setSortOrder(function(a, b, scope)
			return a.getName(scope) < b.getName(scope)
		end)

		expect(root.getChildren(false)).toEqual({ childA, childB, childC, childD })
	end)

	test("specifying the sort function will cascade down to descendants", function()
		local root = createTreeNodeStore()

		local descendant1 = createTreeNodeStore()
		descendant1.parentTo(root)

		local descendant2 = createTreeNodeStore()
		descendant2.parentTo(root)

		local childA = createTreeNodeStore()
		childA.setName("A")

		local childB = createTreeNodeStore()
		childB.setName("B")

		local childC = createTreeNodeStore()
		childC.setName("C")

		local childD = createTreeNodeStore()
		childD.setName("D")

		-- Parent the nodes haphazardly to illustrate how they get sorted
		childC.parentTo(descendant2)
		childD.parentTo(descendant2)
		childA.parentTo(descendant2)
		childB.parentTo(descendant2)

		expect(descendant2.getChildren(false)).toEqual({ childC, childD, childA, childB })

		root.setSortOrder(function(a, b, scope)
			return a.getName(scope) < b.getName(scope)
		end)

		expect(descendant2.getChildren(false)).toEqual({ childA, childB, childC, childD })
	end)

	test("nodes are sorted as they get added", function()
		local root = createTreeNodeStore()

		root.setSortOrder(function(a, b, scope)
			return a.getName(scope) < b.getName(scope)
		end)

		local childA = createTreeNodeStore()
		childA.setName("A")

		local childB = createTreeNodeStore()
		childB.setName("B")

		local childC = createTreeNodeStore()
		childC.setName("C")

		childB.parentTo(root)

		expect(root.getChildren(false)).toEqual({ childB })

		childA.parentTo(root)

		expect(root.getChildren(false)).toEqual({ childA, childB })

		childC.parentTo(root)

		expect(root.getChildren(false)).toEqual({ childA, childB, childC })
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
