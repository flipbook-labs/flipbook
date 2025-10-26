local types = require("./types")

type TreeNodeStore = types.TreeNodeStore

-- FIXME: This is better as a member on TreeNodeStore if we still need it
local function findFirstAncestor(
	descendant: TreeNodeStore,
	predicate: (ancestor: TreeNodeStore) -> boolean
): TreeNodeStore?
	local current = descendant.getParent(false)
	while current do
		if predicate(current) == true then
			return current
		end
		current = current.getParent(false)
	end
	return nil
end

return findFirstAncestor
