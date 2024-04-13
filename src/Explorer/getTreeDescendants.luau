local flipbook = script:FindFirstAncestor("flipbook")

local types = require(flipbook.Explorer.types)

local function getTreeDescendants(root: types.ComponentTreeNode): { types.ComponentTreeNode }
	local descendants: { types.ComponentTreeNode } = {}

	local function traverse(node: types.ComponentTreeNode, isRoot: boolean)
		if not isRoot then
			table.insert(descendants, node)
		end

		for _, child in node.children do
			traverse(child, false)
		end
	end

	traverse(root, true)

	return descendants
end

return getTreeDescendants
