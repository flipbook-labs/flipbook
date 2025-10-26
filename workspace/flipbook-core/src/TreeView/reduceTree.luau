local Sift = require("@pkg/Sift")

local types = require("@root/TreeView/types")

type TreeNodeStore = types.TreeNodeStore
type SearchMatch = (node: TreeNodeStore) -> boolean

local function reduceTree(nodes: { TreeNodeStore }, searchMatch: SearchMatch): { TreeNodeStore }
	local function reduceNodes(accumulator: { TreeNodeStore }, node: TreeNodeStore)
		if searchMatch(node) then
			table.insert(accumulator, node)
			return accumulator
		end

		if #node.getChildren(false) > 0 then
			local children = Sift.List.reduce(node.getChildren(false), reduceNodes, {})

			if #children > 0 then
				table.insert(
					accumulator,
					Sift.Dictionary.join(node, {
						children = children,
					})
				)
			end
		end

		return accumulator
	end

	return Sift.List.reduce(nodes, reduceNodes, {})
end

return reduceTree
