local HttpService = game:GetService("HttpService")

local Sift = require("@pkg/Sift")

local types = require("./types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local function createTreeNodesFromPartials(partialRoots: { PartialTreeNode | TreeNode }): {
	roots: { TreeNode },
	leaves: { TreeNode },
	byId: { [string]: TreeNode },
	expandedByDefault: { TreeNode },
}
	local leaves: { TreeNode } = {}
	local expandedByDefault: { TreeNode } = {}
	local byId: { [string]: TreeNode } = {}

	local function process(partials: { PartialTreeNode | TreeNode }, parent: TreeNode?): { TreeNode }
		local siblings: { TreeNode } = {}

		for _, partial in partials do
			local base: TreeNode = {
				id = HttpService:GenerateGUID(),
				label = "Unknown",
				icon = "none",
				children = {},
				parent = parent,
				isExpanded = false,
			}

			local node = Sift.Dictionary.join(base, partial)

			if node.isExpanded then
				table.insert(expandedByDefault, node)
			end

			if partial.children then
				node.children = if partial.children then process(partial.children, node) else {}
			else
				table.insert(leaves, node)
			end

			byId[node.id] = node
			table.insert(siblings, node)
		end

		return siblings
	end

	return {
		roots = process(partialRoots),
		byId = byId,
		leaves = leaves,
		expandedByDefault = expandedByDefault,
	}
end

return createTreeNodesFromPartials
