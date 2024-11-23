local Sift = require("@pkg/Sift")

local types = require("./types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local function createTreeNodesFromPartials(partialRoots: { PartialTreeNode }): { TreeNode }
	local function process(partials: { PartialTreeNode }, parent: TreeNode?): { TreeNode }
		local siblings: { TreeNode } = {}

		for _, partial in partials do
			local base: TreeNode = {
				label = "Unknown",
				icon = "none",
				children = {},
				parent = parent,
				isExpanded = false,
			}

			local node = Sift.Dictionary.join(base, partial)

			if partial.children then
				node.children = if partial.children then process(partial.children, node) else {}
			end

			table.insert(siblings, node)
		end

		return siblings
	end

	return process(partialRoots)
end

return createTreeNodesFromPartials
