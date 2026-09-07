local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local createTreeNodeStore = require("./createTreeNodeStore")
local renderHook = require("@root/Testing/renderHook")
local types = require("@root/TreeView/types")
local useTreeNodeFilter = require("./useTreeNodeFilter")

type TreeNodeStore = types.TreeNodeStore

local expect = JestGlobals.expect
local test = JestGlobals.test
local act = ReactRoblox.act

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

test("restores expansion state after clearing the filter", function()
	local root = createTreeNodeStore()
	local branch = createTreeNodeStore()
	local matchingLeaf = createTreeNodeStore()

	branch.parentTo(root)
	matchingLeaf.parentTo(branch)
	root.setIsExpanded(true)

	local getHookResult = renderHook(function()
		local isFiltering, setIsFiltering = React.useState(true)
		local filter = if isFiltering
			then function(node: TreeNodeStore)
				return node ~= matchingLeaf
			end
			else nil
		useTreeNodeFilter(root, filter)
		return setIsFiltering
	end)

	expect(root.getIsExpanded()).toBe(true)
	expect(branch.getIsExpanded()).toBe(true)

	act(function()
		getHookResult()(false)
	end)

	expect(root.getIsExpanded()).toBe(true)
	expect(branch.getIsExpanded()).toBe(false)
end)
