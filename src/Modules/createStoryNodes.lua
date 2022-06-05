local Explorer = require(script.Parent.Parent.Components.Explorer)
local types = require(script.Parent.Parent.types)
local isStoryModule = require(script.Parent.isStoryModule)

local function hasStories(instance: Instance): boolean
	for _, descendant in ipairs(instance:GetDescendants()) do
		if isStoryModule(descendant) then
			return true
		end
	end
	return false
end

local function createChildNodes(parent: Explorer.Node, instance: Instance, storybook: types.Storybook)
	for _, child in ipairs(instance:GetChildren()) do
		local isStory = isStoryModule(child)
		local isContainer = hasStories(child)

		if isStory or isContainer then
			local node: Explorer.Node = {
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

local function createStoryNodes(storybooks: { types.Storybook }): { Explorer.Node }
	local nodes: { Explorer.Node } = {}

	for _, storybook in ipairs(storybooks) do
		local node: Explorer.Node = {
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
