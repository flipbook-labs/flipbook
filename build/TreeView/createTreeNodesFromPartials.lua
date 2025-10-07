local HttpService = game:GetService("HttpService")

local Sift = require(script.Parent.Parent.Packages.Sift)

local types = require(script.Parent.types)

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode

local function createTreeNodesFromPartials(partialRoots: { PartialTreeNode | TreeNode }): {
	roots: { TreeNode },
	leaves: { TreeNode },
	byId: { [string]: TreeNode },
	byInstance: { [Instance]: TreeNode },
	expandedByDefault: { TreeNode },
}
	local leaves: { TreeNode } = {}
	local expandedByDefault: { TreeNode } = {}
	local byId: { [string]: TreeNode } = {}
	local byInstance: { [Instance]: TreeNode } = {}

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

			if node.instance then
				byInstance[node.instance] = node
			end

			if partial.children and #partial.children > 0 then
				node.children = process(partial.children, node)
			else
				table.insert(leaves, node)
			end

			byId[node.id] = node
			table.insert(siblings, node)
		end

		table.sort(siblings, function(a, b)
			if a.icon ~= b.icon then
				-- Sort by type
				return a.icon < b.icon
			else
				-- Sort alphabetically
				return a.label:lower() < b.label:lower()
			end
		end)

		return siblings
	end

	return {
		roots = process(partialRoots),
		byId = byId,
		byInstance = byInstance,
		leaves = leaves,
		expandedByDefault = expandedByDefault,
	}
end

return createTreeNodesFromPartials
