local Storyteller = require("@pkg/Storyteller")

local TreeView = require("@root/TreeView")
local createTreeNodeForStoryModule = require("@root/Storybook/createTreeNodeForStoryModule")
local getAncestors = require("@root/Common/getAncestors")

type TreeNodeStore = TreeView.TreeNodeStore
type LoadedStorybook = Storyteller.LoadedStorybook
type LoadedStory<any> = Storyteller.LoadedStory<any>

local function createTreeNodesForStorybook(storybook: LoadedStorybook): TreeNodeStore
	local root = TreeView.createTreeNodeStore()
	root.setName(if storybook.name then storybook.name else "Unnamed Storybook")
	root.setIcon(TreeView.TreeNodeIcon.Storybook)
	root.setInstance(storybook.source)

	for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
		local currentNode = createTreeNodeForStoryModule(storyModule)

		for _, ancestor in getAncestors(storyModule) do
			-- This is probably expensive to be doing so frequently but it seems
			-- to be fine for now. May hit a point where this bit in particular
			-- becomes a bottleneck though
			local existingNode = root.findFirstDescendant(function(descendant)
				return descendant.getInstance(false) == ancestor
			end)

			if existingNode then
				currentNode.parentTo(existingNode)
				break
			end

			if table.find(storybook.storyRoots, ancestor) then
				currentNode.parentTo(root)
				break
			end

			local node = TreeView.createTreeNodeStore()
			node.setName(ancestor.Name)
			node.setIcon(TreeView.TreeNodeIcon.Folder)
			node.setInstance(ancestor)

			currentNode.parentTo(node)
			currentNode = node
		end
	end

	return root
end

return createTreeNodesForStorybook
