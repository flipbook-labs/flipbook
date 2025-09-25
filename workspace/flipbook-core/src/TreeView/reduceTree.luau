local Sift = require("@pkg/Sift")

local types = require("@root/TreeView/types")

type TreeNode = types.TreeNode
type SearchMatch = (node: TreeNode) -> boolean

local function reduceTree(nodes: { TreeNode }, searchMatch: SearchMatch): { TreeNode }
	local function reduceNodes(accumulator: { TreeNode }, node: TreeNode)
		if searchMatch(node) then
			table.insert(accumulator, node)
			return accumulator
		end

		if #node.children > 0 then
			local children = Sift.List.reduce(node.children, reduceNodes, {})

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
