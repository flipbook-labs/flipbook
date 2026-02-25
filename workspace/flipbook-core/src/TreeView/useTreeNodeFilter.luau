local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Sift = require("@pkg/Sift")

local types = require("@root/TreeView/types")

local useSignalState = ReactCharm.useSignalState
local useEffect = React.useEffect

type TreeNodeStore = types.TreeNodeStore
type TreeNodeFilter = types.TreeNodeFilter

local function useTreeNodeFilter(root: TreeNodeStore, filter: TreeNodeFilter?)
	local leaves = useSignalState(root.getLeafNodes)

	useEffect(function()
		if filter then
			-- Resetting the filtered state to do it all over again for the new
			-- filter function
			root.setIsFiltered(false)
			for _, descendant in root.getDescendants() do
				descendant.setIsFiltered(false)
			end

			local included = {}

			for _, leaf in leaves do
				local includeRemainingNodes = false

				-- This orders the nodes starting from the leaf and then each
				-- parent going up the ancestry chain. This is useful so when we
				-- hit at least one node that shouldn't be filtered we know we
				-- have to keep the remaining items after that point unfiltered
				-- too.
				local nodes: { TreeNodeStore } = Sift.List.join({ leaf }, leaf.getAncestors())

				for _, node in nodes do
					-- We've already marked this node as unfiltered, which means
					-- this node and all of the remaining ancestor nodes we'd be
					-- iterating through should also be unfiltered. So we just
					-- exit out here
					if included[node.id] then
						break
					end

					-- If at least one of the nodes in `nodes` shouldn't be
					-- filtered, then all ancestors after that point shouldn't
					-- be filtered either.
					if includeRemainingNodes then
						included[node.id] = true
						node.setIsFiltered(false)
						continue
					end

					if filter(node) then
						node.setIsFiltered(true)
					else
						included[node.id] = true
						node.setIsFiltered(false)
						includeRemainingNodes = true
					end
				end
			end
		end
	end, { filter, leaves } :: { unknown })
end

return useTreeNodeFilter
