local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local Directory = require(script.Directory)
local Story = require(script.Story)
local types = require(flipbook.Explorer.types)
local getTreeDescendants = require(flipbook.Explorer.getTreeDescendants)

local e = React.createElement

local defaultProps = {
	indent = 0,
}

type Props = {
	node: types.ComponentTreeNode,
	filter: string?,
	activeNode: types.ComponentTreeNode?,
	onClick: ((types.ComponentTreeNode) -> ())?,
}

type InternalProps = Props & typeof(defaultProps)

local function Component(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)

	local hasChildren = props.node.children and #props.node.children > 0

	local expanded, setExpanded = React.useState(false)
	local onClick = React.useCallback(function()
		if props.onClick then
			props.onClick(props.node)
		end

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
			children[child.name .. idx] = React.createElement(Component, {
				node = child,
				indent = props.indent + 1,
				filter = props.filter,
				activeNode = props.activeNode,
				onClick = props.onClick,
			})
		end
	end

	if props.filter then
		if props.node.icon == "story" and not props.node.name:lower():match(props.filter:lower()) then
			return
		end

		local isEmpty = true
		for _, descendant in getTreeDescendants(props.node) do
			if descendant.name:lower():match(props.filter:lower()) then
				isEmpty = false
				break
			end
		end

		if isEmpty then
			return
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
				indent = props.indent,
				node = props.node,
				onClick = onClick,
			})
			else e(Story, {
				active = props.activeNode == props.node,
				indent = props.indent,
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

return Component
