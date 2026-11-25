local TreeView = require("@root/TreeView")

type TreeNodeStore = TreeView.TreeNodeStore

local function createTreeNodeForStoryModule(storyModule: ModuleScript): TreeNodeStore
	local name = storyModule.Name:gsub("%.story", "")

	local node = TreeView.createTreeNodeStore()
	node.setName(name)
	node.setIcon(TreeView.TreeNodeIcon.Story)
	node.setInstance(storyModule)

	return node
end

return createTreeNodeForStoryModule
