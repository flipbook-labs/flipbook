local JestGlobals = require("@pkg/JestGlobals")

local createTreeNodeStore = require("./createTreeNodeStore")
local renderHook = require("@root/Testing/renderHook")
local useTreeNodeFilter = require("./useTreeNodeFilter")

local expect = JestGlobals.expect
local test = JestGlobals.test

test("expands ancestors to reveal matching leaves", function()
	local root = createTreeNodeStore()
	local branch = createTreeNodeStore()
	local matchingLeaf = createTreeNodeStore()
	local filteredLeaf = createTreeNodeStore()

	branch.parentTo(root)
	matchingLeaf.parentTo(branch)
	filteredLeaf.parentTo(branch)

	renderHook(function()
		useTreeNodeFilter(root, function(node)
			return node ~= matchingLeaf
		end)
	end)

	expect(root.getIsExpanded()).toBe(true)
	expect(branch.getIsExpanded()).toBe(true)
	expect(matchingLeaf.getIsFiltered()).toBe(false)
	expect(filteredLeaf.getIsFiltered()).toBe(true)
end)

test("does not expand nodes when there is no filter", function()
	local root = createTreeNodeStore()
	local branch = createTreeNodeStore()
	local leaf = createTreeNodeStore()

	branch.parentTo(root)
	leaf.parentTo(branch)
	leaf.setIsFiltered(true)

	renderHook(function()
		useTreeNodeFilter(root, nil)
	end)

	expect(root.getIsExpanded()).toBe(false)
	expect(branch.getIsExpanded()).toBe(false)
	expect(leaf.getIsFiltered()).toBe(false)
end)
