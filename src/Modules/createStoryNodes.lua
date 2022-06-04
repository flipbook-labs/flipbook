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

local function addStoriesToNode(root: Instance, node: Explorer.Node, storybook: types.Storybook)
	-- TODO: Maybe use GetDescendants instead and for every .story file, use
	-- GetFullName() and go up the chain the build the hierarchy
	for _, child in ipairs(root:GetChildren()) do
		local nextNode = {
			name = child.Name,
			instance = child,
			children = {},
		}

		if isStoryModule(child) then
			nextNode.icon = "story"
			nextNode.storybook = storybook
			table.insert(node.children, nextNode)
		else
			if #child:GetChildren() > 0 then
				-- This is why my stories arent showing up. The folders have no
				-- stories as direct descendants so of course they don't show up
				if hasStories(child) then
					nextNode.icon = "folder"
					table.insert(node.children, nextNode)
					addStoriesToNode(child, nextNode, storybook)
				end
			end
		end
	end
end

-- Got an idea for how to construct this: Clone each storyRoot,  loop over the
-- list of descendants for each, and remove any that aren't stories or part of a
-- story's ancestry
--
-- Can then map that right to the story nodes

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
