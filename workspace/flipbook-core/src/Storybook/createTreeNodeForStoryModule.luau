local TreeView = require("@root/TreeView")
local types = require("@root/Storybook/types")

type TreeNodeStore = TreeView.TreeNodeStore
type StoryModuleSnapshot = types.StoryModuleSnapshot

local function createStoryNode(storyModule: ModuleScript, name: string, storyId: string?, order: number?): TreeNodeStore
	local node = TreeView.createTreeNodeStore()
	node.setName(name)
	node.setOrder(order)
	node.setIcon(TreeView.TreeNodeIcon.Story)
	node.setInstance(storyModule)
	node.setStoryId(storyId)

	return node
end

local function createTreeNodeForStoryModule(storyModule: ModuleScript, snapshot: StoryModuleSnapshot?): TreeNodeStore
	local moduleName = storyModule.Name:gsub("%.story", "")

	if snapshot and #snapshot.stories > 1 then
		local groupNode = TreeView.createTreeNodeStore()
		groupNode.setName(snapshot.name)
		groupNode.setIcon(TreeView.TreeNodeIcon.Folder)
		groupNode.setInstance(storyModule)

		for order, story in snapshot.stories do
			local storyNode = createStoryNode(storyModule, story.name, story.id, order)
			storyNode.parentTo(groupNode)
		end

		return groupNode
	end

	local story = if snapshot then snapshot.stories[1] else nil
	return createStoryNode(storyModule, moduleName, if story then story.id else nil, nil)
end

return createTreeNodeForStoryModule
