local flipbook = script:FindFirstAncestor("flipbook")

local Directory = require(script.Directory)
local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local Story = require(script.Story)
local types = require(script.Parent.types)

local e = Roact.createElement

type Props = {
	activeNode: types.Node?,
	indent: number,
	node: types.Node,
	onClick: (types.Node) -> (),
}

local function Component(props: Props, hooks: any)
	local indent = props.indent or 0
	local hasChildren = props.node.children and #props.node.children > 0

	local expanded, setExpanded = hooks.useState(false)
	local onClick = hooks.useCallback(function()
		props.onClick(props.node)

		if hasChildren then
			setExpanded(function(prev)
				return not prev
			end)
		end
	end, { setExpanded })

	local children = {
		UIListLayout = if hasChildren
			then e("UIListLayout", {
				SortOrder = Enum.SortOrder.Name,
			})
			else nil,
	}

	if hasChildren and props.node.children then
		for idx, child in ipairs(props.node.children) do
			children[child.name .. idx] = Roact.createElement(Component, {
				activeNode = props.activeNode,
				indent = indent + 1,
				node = child,
				onClick = props.onClick,
			})
		end
	end

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Node = if props.node.icon ~= "story"
			then e(Directory, {
				expanded = expanded,
				hasChildren = hasChildren,
				indent = indent,
				node = props.node,
				onClick = onClick,
			})
			else e(Story, {
				active = props.activeNode == props.node,
				indent = indent,
				node = props.node,
				onClick = onClick,
			}),

		Children = if expanded and hasChildren
			then e("Frame", {
				AutomaticSize = if expanded then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
			}, children)
			else nil,
	})
end

Component = hook(Component)

return Component
