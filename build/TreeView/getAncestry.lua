local types = require(script.Parent.types)

type TreeNode = types.TreeNode

local function getAncestry(node: TreeNode): { TreeNode }
	local ancestry = {}
	local parent = node.parent
	while parent do
		table.insert(ancestry, parent)
		parent = parent.parent
	end
	return ancestry
end

return getAncestry
