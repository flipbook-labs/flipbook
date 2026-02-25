local HttpService = game:GetService("HttpService")

local Charm = require("@pkg/Charm")
local Sift = require("@pkg/Sift")

local types = require("@root/TreeView/types")

type TreeNodeStore = types.TreeNodeStore
type TreeNodeSnapshot = types.TreeNodeSnapshot
type TreeNodeIcon = types.TreeNodeIcon
type TreeNodeSort = types.TreeNodeSort

local function createTreeNodeStore(): TreeNodeStore
	local id = HttpService:GenerateGUID()

	local getName, setName = Charm.signal("Node")
	local getIcon, setIcon = Charm.signal(nil :: TreeNodeIcon?)
	local getIsSelected, setIsSelected = Charm.signal(false)
	local getIsExpanded, setIsExpanded = Charm.signal(false)
	local getIsVisible, setIsVisible = Charm.signal(true)
	local getIsFiltered, setIsFiltered = Charm.signal(false)
	local getIsPinned, setIsPinned = Charm.signal(false)

	local getInstance, setInstance = Charm.signal(nil :: Instance?)

	local getParent, setParent = Charm.signal(nil :: TreeNodeStore?)
	local getUnsortedChildren, setUnsortedChildren = Charm.signal({} :: { TreeNodeStore })

	local getSortOrder, setSortOrderSignal = Charm.signal(nil :: TreeNodeSort?)

	local self: TreeNodeStore

	local getChildren = Charm.computed(function()
		local children = table.clone(getUnsortedChildren())
		local sort = getSortOrder()

		if sort then
			table.sort(children, function(a, b)
				return sort(a, b)
			end)
		end

		return children
	end)

	local getAncestors = Charm.computed(function()
		local ancestors: { TreeNodeStore } = {}
		local candidate: TreeNodeStore? = getParent()

		while candidate do
			table.insert(ancestors, candidate)
			candidate = candidate.getParent()
		end

		return ancestors
	end)

	local getDescendants = Charm.computed(function()
		local descendants: { TreeNodeStore } = {}
		local stack = table.clone(getUnsortedChildren())

		while #stack > 0 do
			local candidate = table.remove(stack)
			if candidate then
				table.insert(descendants, candidate)
				stack = Sift.List.join(stack, candidate.getChildren())
			end
		end

		return descendants
	end)

	local function setSortOrder(sort: TreeNodeSort?)
		setSortOrderSignal(function()
			-- FIXME: Need to cast to `any` here. It's suspected this is related
			-- to how Signals types its setter functions, where it can take
			-- either a value or an update function. Since we _want_ to store a
			-- function, that might be what's tripping it up
			return sort :: any
		end)

		-- Because this isn't scoped newly added descendants won't have the same
		-- sorting function. This is aleviated by parentTo assigning the new
		-- parent's sorting function to the node being moved
		for _, descendant in getDescendants() do
			descendant.setSortOrder(sort)
		end
	end

	local function createDescendantMatcher(predicate: (descendant: TreeNodeStore) -> boolean?): () -> { TreeNodeStore }
		return Charm.computed(function()
			local matches = {}
			for _, descendant in getDescendants() do
				local result = predicate(descendant)
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

	local getRoot = Charm.computed(function()
		local ancestors = getAncestors()
		return ancestors[#ancestors]
	end)

	local getPath = Charm.computed(function()
		local path = getName()
		for _, ancestor in getAncestors() do
			path = `{ancestor.getName()}/{path}`
		end
		return path
	end)

	local getLeafNodes = createDescendantMatcher(function(descendant)
		return #descendant.getChildren() == 0
	end)

	local getSelectedDescendants = createDescendantMatcher(function(descendant)
		return descendant.getIsSelected()
	end)

	local getPinnedDescendants = createDescendantMatcher(function(descendant)
		return descendant.getIsPinned()
	end)

	local function findFirstDescendant(predicate: (node: TreeNodeStore) -> boolean): TreeNodeStore?
		for _, descendant in getDescendants() do
			if predicate(descendant) then
				return descendant
			end
		end
		return nil
	end

	local function findFirstAncestor(predicate: (node: TreeNodeStore) -> boolean): TreeNodeStore?
		for _, ancestor in getAncestors() do
			if predicate(ancestor) then
				return ancestor
			end
		end
		return nil
	end

	local function parentTo(newParent: TreeNodeStore?)
		local parent = getParent()

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
			setSortOrder(newParent.getSortOrder())
		end
	end

	local function clearChildren()
		for _, child in getChildren() do
			child.parentTo(nil)
		end
	end

	local function expandDown()
		setIsExpanded(true)
		for _, descendant in getDescendants() do
			descendant.setIsExpanded(true)
		end
	end

	local function expandUp()
		setIsExpanded(true)
		for _, ancestor in getAncestors() do
			ancestor.setIsExpanded(true)
		end
	end

	local function collapseDown()
		setIsExpanded(false)
		for _, ancestor in getDescendants() do
			ancestor.setIsExpanded(false)
		end
	end

	local function activate()
		if #getUnsortedChildren() > 0 then
			setIsExpanded(function(prev)
				return not prev
			end)
		else
			local root = getRoot()
			if root then
				for _, selection in root.getSelectedDescendants() do
					if selection ~= self then
						selection.setIsSelected(false)
					end
				end
			end

			setIsSelected(function(prev)
				return not prev
			end)
		end
	end

	local function snapshot(): TreeNodeSnapshot
		local root = {
			id = id,
			name = getName(),
			icon = getIcon(),
			isVisible = getIsVisible(),
			isSelected = getIsSelected(),
			children = {},
		}

		for _, child in getUnsortedChildren() do
			table.insert(root.children, child.snapshot())
		end

		return root
	end

	self = {
		id = id,

		-- Node properties and states
		getName = getName,
		setName = setName,
		getIcon = getIcon :: () -> TreeNodeIcon?,
		setIcon = (setIcon :: any) :: (TreeNodeIcon? | (TreeNodeIcon?) -> TreeNodeIcon?) -> TreeNodeIcon?,
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
		getPath = getPath,

		-- DataModel
		getInstance = getInstance,
		setInstance = setInstance,

		-- Other
		snapshot = snapshot,
	}

	return self
end

return createTreeNodeStore
