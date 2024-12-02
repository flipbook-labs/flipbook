local Storyteller = require("@pkg/Storyteller")

local types = require("./types")

type PartialTreeNode = types.PartialTreeNode
type TreeNode = types.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook
type LoadedStory<any> = Storyteller.LoadedStory<any>

local function creaTreeNodesForStorybook(storybook: LoadedStorybook): {
	root: TreeNode,
	leaves: { TreeNode },
	nodesByInstance: { [Instance]: TreeNode },
}
	local leaves: { TreeNode } = {}
	local nodesByInstance: { [Instance]: TreeNode } = {}

	local root: TreeNode = {
		label = if storybook.name then storybook.name else "Unnamed Storybook",
		icon = "storybook",
		isExpanded = false,
		children = {},
	}

	for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
		local currentNode: TreeNode = {
			label = storyModule.Name,
			icon = "story",
			isExpanded = false,
			children = {},
		}

		table.insert(leaves, currentNode)

		local parentInstance = storyModule.Parent

		while parentInstance do
			local existingParentNode = nodesByInstance[parentInstance]

			if existingParentNode then
				if table.find(storybook.storyRoots, parentInstance) then
					table.insert(root.children, existingParentNode)
					break
				end

				table.insert(existingParentNode.children, currentNode)
			else
				local parentNode: TreeNode = {
					label = parentInstance.Name,
					icon = "folder",
					isExpanded = false,
					children = { currentNode },
				}

				nodesByInstance[parentInstance] = parentNode
				currentNode = parentNode
			end

			parentInstance = parentInstance.Parent
		end
	end

	return {
		root = root,
		leaves = leaves,
		nodesByInstance = nodesByInstance,
	}
end

return creaTreeNodesForStorybook
