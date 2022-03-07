local hook = require(script.Parent.Parent.Parent.hook)
local Icon = require(script.Parent.Parent.Icon)
local Llama = require(script.Parent.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local RoactSpring = require(script.Parent.Parent.Parent.Packages.RoactSpring)
local styles = require(script.Parent.Parent.Parent.styles)
local types = require(script.Parent.types)
local useTheme = require(script.Parent.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

export type Props = {
	node: types.Node,
	activeNode: types.Node?,
	onNodeActivated: (types.Node) -> (),
	indentLevel: number,
}

-- TODO: Remove this function, figure out
-- a better way to solve this. Don't really
-- care atm.
local function deriveIconSize(icon: string): UDim2
	if icon == "folder" then
		return UDim2.fromOffset(14, 10)
	elseif icon == "story" then
		return UDim2.fromOffset(14, 14)
	end
end

local function ExplorerNode(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local isExpanded, setIsExpanded = hooks.useState(false)

	local hasChildren = props.node.children and #props.node.children > 0
	local indentLevel = props.indentLevel or 0
	local onActivated = hooks.useCallback(function()
		if hasChildren then
			setIsExpanded(not isExpanded)
		end
	end, { isExpanded, setIsExpanded })

	local children = {}
	if hasChildren then
		children.UIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.Name,
		})

		if props.node.children then
			for index, child in ipairs(props.node.children) do
				children[child.name .. index] = e(ExplorerNode, {
					node = child,
					activeNode = props.activeNode,
					onNodeActivated = props.onNodeActivated,
					indentLevel = indentLevel + 1,
				})
			end
		end
	end

	return e("ImageButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 0),
		[Roact.Event.Activated] = onActivated,
	}, {
		UIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Node = e("Frame", {
			BackgroundColor3 = theme.entry.background,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 32),
		}, {
			UIPadding = e("UIPadding", {
				PaddingLeft = UDim.new(0, styles.PADDING.Offset * indentLevel + 1),
			}),

			Icon = e(Icon, {
				anchorPoint = Vector2.new(0, 0.5),
				color = theme.icons[props.node.icon],
				icon = props.node.icon,
				position = UDim2.new(0, 30, 0.5, 0),
				size = deriveIconSize(props.node.icon),
			}),

			Name = e(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 55, 0.5, 0),
					Text = props.node.name,
					TextColor3 = theme.entry.text,
					TextSize = 12,
				})
			),
		}),

		ChildrenWrapper = (isExpanded and hasChildren) and e("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = if isExpanded then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
			BackgroundTransparency = 1,
		}, children),
	})
end

ExplorerNode = hook(ExplorerNode)

return ExplorerNode
