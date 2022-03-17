local Explorer = require(script.Parent.Parent.Components.Explorer)
local constants = require(script.Parent.Parent.constants)
local types = require(script.Parent.Parent.types)

local function addStoriesToNode(root: Instance, node: Explorer.Node, storybook: types.Storybook)
	for _, child in ipairs(root:GetChildren()) do
		local nextNode = {
			name = child.Name,
			instance = child,
			children = {},
		}

		if child.Name:match(constants.STORY_NAME_PATTERN) then
			nextNode.icon = "story"
			nextNode.storybook = storybook
			table.insert(node.children, nextNode)
		else
			if #child:GetChildren() > 0 then
				nextNode.icon = "folder"
				table.insert(node.children, nextNode)
				addStoriesToNode(child, nextNode, storybook)
			end
		end
	end
end

local function createStoryNodes(storybooks: { types.Storybook }): { Explorer.Node }
	local nodes = {}

	for _, storybook in ipairs(storybooks) do
		local node = {
			name = storybook.name,
			icon = "storybook",
			children = {},
		}

		table.insert(nodes, node)

		for _, root in ipairs(storybook.storyRoots) do
			addStoriesToNode(root, node, storybook)
		end
	end

	return nodes
end

return createStoryNodes
