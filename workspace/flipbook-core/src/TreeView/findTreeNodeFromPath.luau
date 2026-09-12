local types = require("@root/TreeView/types")

type TreeNodeStore = types.TreeNodeStore

local function findTreeNodeFromPath(root: TreeNodeStore, path: string): TreeNodeStore?
	local fullPath = `{root.getPath()}/{path}`
	return root.findFirstDescendant(function(descendant)
		return descendant.getPath() == fullPath
	end)
end

return findTreeNodeFromPath
