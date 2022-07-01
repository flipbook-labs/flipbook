local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Component = require(script.Component)
local types = require(script.types)

local e = Roact.createElement

export type Node = types.Node
export type Props = {
	activeNode: types.Node?,
	layoutOrder: number,
	nodes: { types.Node },
	onClick: (types.Node) -> (),
}

local function ComponentTree(props: Props)
	local children = {}

	children.UIListLayoutLayout = e("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
	})

	-- children.UIPadding = e("UIPadding", {
	-- 	PaddingBottom = UDim.new(0, 0),
	-- 	PaddingLeft = UDim.new(0, 0),
	-- 	PaddingRight = UDim.new(0, 5),
	-- 	PaddingTop = UDim.new(0, 0),
	-- })

	for index, node in ipairs(props.nodes) do
		children[node.name .. index] = e(Component, {
			activeNode = props.activeNode,
			node = node,
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
