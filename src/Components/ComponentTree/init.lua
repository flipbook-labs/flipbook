local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Component = require(script.Component)
local types = require(script.types)

local e = Roact.createElement

export type Node = types.Node
export type Props = {
	nodes: { types.Node },
	activeNode: types.Node?,
	layoutOrder: number?,
	filter: string?,
	onClick: ((types.Node) -> ())?,
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
