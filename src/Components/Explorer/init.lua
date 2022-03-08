local Roact = require(script.Parent.Parent.Packages.Roact)
local ExplorerNode = require(script.ExplorerNode)
local types = require(script.types)

local e = Roact.createElement

export type Node = types.Node
export type Props = {
	activeNode: types.Node?,
	nodes: { types.Node },
	onNodeActivated: (types.Node) -> (),
}

local function Explorer(props: Props)
	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
	})

	for index, node in ipairs(props.nodes) do
		children[node.name .. index] = e(ExplorerNode, {
			activeNode = props.activeNode,
			node = node,
			onNodeActivated = props.onNodeActivated,
		})
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, children)
end

return Explorer
