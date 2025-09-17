local HttpService = game:GetService("HttpService")

local Storyteller = require("@pkg/Storyteller")
local TreeView = require("@root/TreeView")

type PartialTreeNode = TreeView.PartialTreeNode
type TreeNode = TreeView.TreeNode
type LoadedStorybook = Storyteller.LoadedStorybook
type LoadedStory<any> = Storyteller.LoadedStory<any>

local function createTreeNodesForStorybook(storybook: LoadedStorybook): TreeNode
	local nodesByInstance: { [Instance]: TreeNode } = {}

	local root: TreeNode = {
		id = HttpService:GenerateGUID(),
		label = if storybook.name then storybook.name else "Unnamed Storybook",
		icon = "storybook",
		isExpanded = false,
		children = {},
	}

	for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook) do
		local currentNode: TreeNode = {
			id = HttpService:GenerateGUID(),
			label = storyModule.Name:gsub("%.story", ""),
			icon = "story",
			isExpanded = false,
			instance = storyModule,
			children = {},
		}

		local parentInstance = storyModule.Parent

		while parentInstance do
			if table.find(storybook.storyRoots, parentInstance) then
				table.insert(root.children, currentNode)
				break
			end

			local existingParentNode = nodesByInstance[parentInstance]

			if existingParentNode then
				table.insert(existingParentNode.children, currentNode)
				break
			else
				local parentNode: TreeNode = {
					id = HttpService:GenerateGUID(),
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

	return root
end

return createTreeNodesForStorybook
