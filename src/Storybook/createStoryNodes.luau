local Storyteller = require("@pkg/Storyteller")

local explorerTypes = require("@root/Explorer/types")

type Storybook = Storyteller.Storybook
type ComponentTreeNode = explorerTypes.ComponentTreeNode

local function hasStories(instance: Instance): boolean
	for _, descendant in ipairs(instance:GetDescendants()) do
		if Storyteller.isStoryModule(descendant) then
			return true
		end
	end
	return false
end

local function createChildNodes(parent: ComponentTreeNode, instance: Instance, storybook: Storybook)
	for _, child in ipairs(instance:GetChildren()) do
		local isStory = Storyteller.isStoryModule(child)
		local isContainer = hasStories(child)

		if isStory or isContainer then
			local node: ComponentTreeNode = {
				name = child.Name,
				instance = child,
				children = {},

				icon = if isStory then "story" else "folder",
				storybook = if isStory then storybook else nil,
			}

			table.insert(parent.children, node)

			if not isStory and isContainer then
				createChildNodes(node, child, storybook)
			end
		end
	end
end

local function createStoryNodes(storybooks: { Storybook }): { ComponentTreeNode }
	local nodes: { ComponentTreeNode } = {}

	for _, storybook in ipairs(storybooks) do
		local node: ComponentTreeNode = {
			name = if storybook.name then storybook.name else "Unnamed Storybook",
			icon = "storybook" :: "storybook",
			children = {},
		}

		table.insert(nodes, node)

		for _, root in ipairs(storybook.storyRoots) do
			createChildNodes(node, root, storybook)
		end
	end

	return nodes
end

return createStoryNodes
