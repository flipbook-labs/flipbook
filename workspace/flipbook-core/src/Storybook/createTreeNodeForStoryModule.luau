local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView")

type TreeNodeStore = TreeView.TreeNodeStore
type StoryModuleRecord = Storyteller.StoryModuleRecord

local function createStoryNode(storyModule: ModuleScript, name: string, storyId: string?, order: number?): TreeNodeStore
	local node = TreeView.createTreeNodeStore()
	node.setName(name)
	node.setOrder(order)
	node.setIcon(TreeView.TreeNodeIcon.Story)
	node.setInstance(storyModule)
	node.setStoryId(storyId)

	return node
end

local function createTreeNodeForStoryModule(storyModule: ModuleScript, record: StoryModuleRecord?): TreeNodeStore
	local moduleName = storyModule.Name:gsub("%.story", "")
	local stories = if record then record.stories else nil

	if stories and #stories > 1 then
		local groupNode = TreeView.createTreeNodeStore()
		groupNode.setName(if record and record.name then record.name else moduleName)
		groupNode.setIcon(TreeView.TreeNodeIcon.Folder)
		groupNode.setInstance(storyModule)

		for order, story in stories do
			local storyNode = createStoryNode(storyModule, story.name, story.id, order)
			storyNode.parentTo(groupNode)
		end

		return groupNode
	end

	local story = if stories then stories[1] else nil
	return createStoryNode(storyModule, moduleName, if story then story.id else nil, nil)
end

return createTreeNodeForStoryModule
