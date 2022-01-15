local Roact = require(script.Parent.Parent.Packages.Roact)
local TreeNode = require(script.TreeNode)
local types = require(script.types)

export type Props = {
	nodes: { types.Node },
	activeNode: types.Node?,
	onNodeActivated: (types.Node) -> nil,
}

export type Node = types.Node

local function TreeList(props: Props)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 4),
	})

	for index, node in ipairs(props.nodes) do
		children[node.name .. index] = Roact.createElement(TreeNode, {
			node = node,
			activeNode = props.activeNode,
			onNodeActivated = props.onNodeActivated,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, children)
end

return TreeList
