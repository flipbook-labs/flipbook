local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local TreeNode = require(script.TreeNode)
local types = require(script.types)

export type Props = {
	nodes: { types.Node },
	onNodeActivated: (types.Node) -> nil,
}

export type Node = types.Node

local function TreeList(props: Props)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 4),
	})

	children.Padding = Roact.createElement("UIPadding", {
		PaddingTop = styles.PADDING,
		PaddingRight = styles.PADDING,
		PaddingBottom = styles.PADDING,
		PaddingLeft = styles.PADDING,
	})

	for index, node in ipairs(props.nodes) do
		children[node.name .. index] = Roact.createElement(TreeNode, {
			node = node,
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
