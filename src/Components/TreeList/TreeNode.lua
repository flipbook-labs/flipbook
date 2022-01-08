local Llama = require(script.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Parent.Packages.RoactHooks)
local assets = require(script.Parent.Parent.Parent.assets)
local styles = require(script.Parent.Parent.Parent.styles)
local types = require(script.Parent.types)

local NODE_HEIGHT = styles.TextLabel.TextSize

export type Props = {
	node: types.Node,
	onNodeActivated: (types.Node) -> nil,
	indentLevel: number,
}

local defaultProps = {
	indentLevel = 0,
}

local function TreeNode(props: Props, hooks: any)
	props = Llama.Dictionary.join(defaultProps, props)

	local isExpanded, setIsExpanded = hooks.useState(false)
	local hasChildren = props.node.children and #props.node.children > 0
	local nextIndentLevel = props.indentLevel + 1

	local onActivated = hooks.useCallback(function()
		props.onNodeActivated(props.node)

		if hasChildren then
			setIsExpanded(not isExpanded)
		end
	end, { isExpanded, setIsExpanded })

	local children = {}

	if hasChildren then
		children.Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = if isExpanded then styles.SMALL_PADDING else nil,
		})

		if props.node.children then
			for _, child in ipairs(props.node.children) do
				children[child.name] = Roact.createElement(TreeNode, {
					node = child,
					onNodeActivated = props.onNodeActivated,
					indentLevel = nextIndentLevel,
				})
			end
		end
	end

	return Roact.createElement("ImageButton", {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		[Roact.Event.Activated] = onActivated,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = if isExpanded then styles.SMALL_PADDING else nil,
		}),

		Node = Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, NODE_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = styles.SMALL_PADDING,
			}),

			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				Image = props.node.icon,
				Size = UDim2.fromOffset(NODE_HEIGHT, NODE_HEIGHT),
				BackgroundTransparency = 1,
			}),

			Text = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					LayoutOrder = 2,
					Text = props.node.name,
					TextSize = NODE_HEIGHT,
					Size = UDim2.fromOffset(0, NODE_HEIGHT),
					AutomaticSize = Enum.AutomaticSize.X,
				})
			),

			-- Need to wrap the arrow ImageLabel so that rotation can be applied
			ArrowWrapper = hasChildren and Roact.createElement("Frame", {
				LayoutOrder = 3,
				Size = UDim2.fromOffset(NODE_HEIGHT, NODE_HEIGHT),
				BackgroundTransparency = 1,
			}, {
				Arrow = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(1, 1),
					Image = assets["chevron-right"],
					BackgroundTransparency = 1,
					Rotation = if isExpanded then 90 else 0,
				}),
			}),
		}),

		ChildrenWrapper = (isExpanded and hasChildren) and Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = if isExpanded then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
		}, {
			Indent = Roact.createElement("Frame", {
				Position = UDim2.fromOffset(nextIndentLevel * styles.PADDING.Offset, 0),
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, children),
		}),
	})
end

-- We need to redefine TreeNode with RoactHooks so that when we recursively
-- create TreeNodes the hooks are setup properly
TreeNode = RoactHooks.new(Roact)(TreeNode)

return TreeNode
