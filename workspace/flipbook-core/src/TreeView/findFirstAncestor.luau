local types = require("./types")

type TreeNode = types.TreeNode

local function findFirstAncestor(descendant: TreeNode, predicate: (ancestor: TreeNode) -> boolean): TreeNode?
	local current = descendant.parent
	while current do
		if predicate(current) == true then
			return current
		end
		current = current.parent
	end
	return nil
end

return findFirstAncestor
