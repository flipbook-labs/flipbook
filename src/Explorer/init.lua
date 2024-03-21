local React = require("@pkg/React")
local Component = require("./Component")
local types = require("./types")

local e = React.createElement

export type Node = types.ComponentTreeNode
export type Props = {
	nodes: { types.ComponentTreeNode },
	activeNode: types.ComponentTreeNode?,
	layoutOrder: number?,
	filter: string?,
	onClick: ((types.ComponentTreeNode) -> ())?,
}

local function ComponentTree(props: Props)
	local children = {}

	children.UIListLayoutLayout = e("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
	})

	for index, node in ipairs(props.nodes) do
		children[node.name .. index] = e(Component, {
			node = node,
			activeNode = props.activeNode,
			filter = props.filter,
			onClick = props.onClick,
		})
	end

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, children)
end

return ComponentTree
