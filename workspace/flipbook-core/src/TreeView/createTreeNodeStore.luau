local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")

local types = require("@root/TreeView/types")

type TreeNodeStore = types.TreeNodeStore

local function createTreeNodeStore(): TreeNodeStore
	local id = HttpService:GenerateGUID()

	local getName, setName = Signals.createSignal("Node")
	local getIcon, setIcon = Signals.createSignal(nil :: types.TreeNodeIcon?)
	local getIsSelected, setIsSelected = Signals.createSignal(false)
	local getIsExpanded, setIsExpanded = Signals.createSignal(false)

	local getInstance, setInstance = Signals.createSignal(nil :: Instance?)

	local getParent, setParent = Signals.createSignal(nil :: TreeNodeStore?)
	local getChildren, setChildren = Signals.createSignal({} :: { TreeNodeStore })

	local self: TreeNodeStore

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
		local stack = getChildren(scope)

		while #stack > 0 do
			local candidate = table.remove(stack)
			if candidate then
				table.insert(descendants, candidate)
				stack = Sift.List.join(stack, candidate.getChildren(scope))
			end
		end

		return descendants
	end)

	local function parentTo(newParent: TreeNodeStore?)
		local parent = getParent(false)

		if parent then
			parent.setChildren(function(prev)
				return Sift.List.filter(prev, function(otherNode)
					return otherNode.id ~= id
				end)
			end)
		end

		setParent(newParent)

		if newParent then
			newParent.setChildren(function(prev)
				return Sift.List.append(prev, self)
			end)
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

	self = {
		id = id,

		-- Node properties and states
		getName = getName,
		setName = setName,
		getIcon = getIcon,
		setIcon = setIcon,
		getIsSelected = getIsSelected,
		setIsSelected = setIsSelected,

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
		getParent = getParent,
		parentTo = parentTo,
		setChildren = setChildren,

		-- DataModel
		getInstance = getInstance,
		setInstance = setInstance,
	}

	return self
end

return createTreeNodeStore
