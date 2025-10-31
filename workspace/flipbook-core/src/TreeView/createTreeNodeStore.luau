local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")

local types = require("@root/TreeView/types")

type TreeNodeStore = types.TreeNodeStore
type TreeNodeSnapshot = types.TreeNodeSnapshot
type TreeNodeIcon = types.TreeNodeIcon
type TreeNodeSort = types.TreeNodeSort

local function createTreeNodeStore(): TreeNodeStore
	local id = HttpService:GenerateGUID()

	local getName, setName = Signals.createSignal("Node")
	local getIcon, setIcon = Signals.createSignal(nil :: TreeNodeIcon?)
	local getIsSelected, setIsSelected = Signals.createSignal(false)
	local getIsExpanded, setIsExpanded = Signals.createSignal(false)
	local getIsVisible, setIsVisible = Signals.createSignal(true)
	local getIsFiltered, setIsFiltered = Signals.createSignal(false)
	local getIsPinned, setIsPinned = Signals.createSignal(false)

	local getInstance, setInstance = Signals.createSignal(nil :: Instance?)

	local getParent, setParent = Signals.createSignal(nil :: TreeNodeStore?)
	local getUnsortedChildren, setUnsortedChildren = Signals.createSignal({} :: { TreeNodeStore })

	local getSortOrder, setSortOrderSignal = Signals.createSignal(nil :: TreeNodeSort?)

	local self: TreeNodeStore

	local getChildren = Signals.createComputed(function(scope)
		local children = table.clone(getUnsortedChildren(scope))
		local sort = getSortOrder(scope)

		if sort then
			table.sort(children, function(a, b)
				return sort(a, b, scope)
			end)
		end

		return children
	end)

	local getAncestors = Signals.createComputed(function(scope)
		local ancestors: { TreeNodeStore } = {}
		local candidate: TreeNodeStore? = getParent(scope)

		while candidate do
			table.insert(ancestors, candidate)
			candidate = candidate.getParent(scope)
		end

		return ancestors
	end)

	local getDescendants = Signals.createComputed(function(scope)
		local descendants: { TreeNodeStore } = {}
		local stack = table.clone(getUnsortedChildren(scope))

		while #stack > 0 do
			local candidate = table.remove(stack)
			if candidate then
				table.insert(descendants, candidate)
				stack = Sift.List.join(stack, candidate.getChildren(scope))
			end
		end

		return descendants
	end)

	local function setSortOrder(sort: TreeNodeSort?)
		setSortOrderSignal(function()
			return sort
		end)

		-- Because this isn't scoped newly added descendants won't have the same
		-- sorting function. This is aleviated by parentTo assigning the new
		-- parent's sorting function to the node being moved
		for _, descendant in getDescendants(false) do
			descendant.setSortOrder(sort)
		end
	end

	local function createDescendantMatcher(
		predicate: (descendant: TreeNodeStore, scope: Signals.scope) -> boolean?
	): Signals.getter<{ TreeNodeStore }>
		return Signals.createComputed(function(scope)
			local matches = {}
			for _, descendant in getDescendants(scope) do
				local result = predicate(descendant, scope)
				if result == true then
					table.insert(matches, descendant)
				elseif result == false then
					continue
				elseif result == nil then
					break
				end
			end
			return matches
		end)
	end

	local getLeafNodes = createDescendantMatcher(function(descendant, scope)
		return #descendant.getChildren(scope) == 0
	end)

	local getSelectedDescendants = createDescendantMatcher(function(descendant, scope)
		return descendant.getIsSelected(scope)
	end)

	local getPinnedDescendants = createDescendantMatcher(function(descendant, scope)
		return descendant.getIsPinned(scope)
	end)

	local function findFirstDescendant(predicate: (node: TreeNodeStore) -> boolean): TreeNodeStore?
		for _, descendant in getDescendants(false) do
			if predicate(descendant) then
				return descendant
			end
		end
		return nil
	end

	local function findFirstAncestor(predicate: (node: TreeNodeStore) -> boolean): TreeNodeStore?
		for _, ancestor in getAncestors(false) do
			if predicate(ancestor) then
				return ancestor
			end
		end
		return nil
	end

	local function parentTo(newParent: TreeNodeStore?)
		local parent = getParent(false)

		if parent ~= nil then
			if newParent == parent then
				return
			end

			parent.setChildren(function(prev)
				return Sift.List.filter(prev, function(otherNode)
					return otherNode.id ~= id
				end)
			end)
		end

		setParent(newParent)

		if newParent ~= nil then
			newParent.setChildren(function(prev)
				return Sift.List.join(prev, { self })
			end)

			-- Inherit the sorting function from the new parent
			setSortOrder(newParent.getSortOrder(false))
		end
	end

	local function clearChildren()
		for _, child in getChildren(false) do
			child.parentTo(nil)
		end
	end

	local function expandDown()
		setIsExpanded(true)
		for _, descendant in getDescendants(false) do
			descendant.setIsExpanded(true)
		end
	end

	local function expandUp()
		setIsExpanded(true)
		for _, ancestor in getAncestors(false) do
			ancestor.setIsExpanded(true)
		end
	end

	local function collapseDown()
		setIsExpanded(false)
		for _, ancestor in getDescendants(false) do
			ancestor.setIsExpanded(false)
		end
	end

	local function activate()
		if #getUnsortedChildren(false) > 0 then
			setIsExpanded(function(prev)
				return not prev
			end)
		else
			setIsSelected(function(prev)
				return not prev
			end)
		end
	end

	local function snapshot(): TreeNodeSnapshot
		local root = {
			id = id,
			name = getName(false),
			icon = getIcon(false),
			isVisible = getIsVisible(false),
			isSelected = getIsSelected(false),
			children = {},
		}

		for _, child in getUnsortedChildren(false) do
			table.insert(root.children, child.snapshot())
		end

		return root
	end

	self = {
		id = id,

		-- Node properties and states
		getName = getName,
		setName = setName,
		getIcon = getIcon,
		setIcon = setIcon,
		getIsVisible = getIsVisible,
		setIsVisible = setIsVisible,
		getIsSelected = getIsSelected,
		setIsSelected = setIsSelected,
		activate = activate,
		setIsFiltered = setIsFiltered,
		getIsFiltered = getIsFiltered,
		setIsPinned = setIsPinned,
		getIsPinned = getIsPinned,
		getLeafNodes = getLeafNodes,

		-- Expand/Collapse
		collapseDown = collapseDown,
		expandDown = expandDown,
		expandUp = expandUp,
		getIsExpanded = getIsExpanded,
		setIsExpanded = setIsExpanded,

		-- Hierarchy
		getAncestors = getAncestors,
		getChildren = getChildren,
		getDescendants = getDescendants,
		getSelectedDescendants = getSelectedDescendants,
		getPinnedDescendants = getPinnedDescendants,
		getParent = getParent,
		parentTo = parentTo,
		clearChildren = clearChildren,
		setChildren = setUnsortedChildren,
		findFirstAncestor = findFirstAncestor,
		findFirstDescendant = findFirstDescendant,
		getSortOrder = getSortOrder,
		setSortOrder = setSortOrder,

		-- DataModel
		getInstance = getInstance,
		setInstance = setInstance,

		-- Other
		snapshot = snapshot,
	}

	return self
end

return createTreeNodeStore
