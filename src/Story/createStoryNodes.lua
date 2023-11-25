local flipbook = script:FindFirstAncestor("flipbook")

local isStoryModule = require(flipbook.Story.isStoryModule)
local types = require(script.Parent.Parent.types)

local function hasStories(instance: Instance): boolean
	for _, descendant in ipairs(instance:GetDescendants()) do
		if isStoryModule(descendant) then
			return true
		end
	end
	return false
end

local function createChildNodes(parent: types.ComponentTreeNode, instance: Instance, storybook: types.Storybook)
	for _, child in ipairs(instance:GetChildren()) do
		local isStory = isStoryModule(child)
		local isContainer = hasStories(child)

		if isStory or isContainer then
			local node: types.ComponentTreeNode = {
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

local function createStoryNodes(storybooks: { types.Storybook }): { types.ComponentTreeNode }
	local nodes: { types.ComponentTreeNode } = {}

	for _, storybook in ipairs(storybooks) do
		local node: types.ComponentTreeNode = {
			name = storybook.name,
			icon = "storybook",
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
