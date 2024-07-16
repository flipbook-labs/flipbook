local getTreeDescendants = require("./getTreeDescendants")
local types = require("./types")

local function filterComponentTreeNode(node: types.ComponentTreeNode, filter: string): boolean
	if node.icon == "story" then
		if not node.name:lower():match(filter:lower()) then
			return true
		end

		return false
	end

	local isEmpty = true
	for _, descendant in getTreeDescendants(node) do
		if descendant.name:lower():match(filter:lower()) then
			isEmpty = false
			break
		end
	end

	return isEmpty
end

return filterComponentTreeNode
