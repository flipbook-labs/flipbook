local HttpService = game:GetService("HttpService")

local types = require("./types")

type TreeNode = types.TreeNode

local function createTreeNodesFromInstance(instance: Instance): TreeNode
	local currentNode = {
		id = HttpService:GenerateGUID(),
		label = instance.Name,
		children = {},
	}

	local parent = instance.Parent
	while parent do
		local parentNode = {
			id = HttpService:GenerateGUID(),
			label = parent.Name,
			children = { currentNode },
		}

		currentNode.parent = parentNode
		currentNode = parentNode
		parent = parent.Parent
	end

	return currentNode
end

return createTreeNodesFromInstance
