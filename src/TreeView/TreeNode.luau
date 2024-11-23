local React = require("@pkg/React")

local Sprite = require("@root/Common/Sprite")
local types = require("@root/TreeView/types")
local useTreeNodeIcon = require("@root/TreeView/useTreeNodeIcon")
local useTheme = require("@root/Common/useTheme")
local assets = require("@root/assets")

local useCallback = React.useCallback
local useMemo = React.useMemo
local useState = React.useState

type TreeNode = types.TreeNode

export type Props = {
	node: TreeNode,
	onActivated: (() -> ())?,
	layoutOrder: number?,
}

local function TreeNode(props: Props)
	local theme = useTheme()
	local icon, iconColor = useTreeNodeIcon(props.node.icon)

	local isExpanded, setIsExpanded = useState(props.node.isExpanded)

	local children = useMemo(function()
		local elements: { [string]: React.Node } = {}
		if props.node.children then
			for index, child in props.node.children do
				elements[child.label] = React.createElement(TreeNode, {
					layoutOrder = index,
					node = child,
				})
			end
		end
		return elements
	end, { props.node.children })

	local onActivated = useCallback(function()
		if props.onActivated then
			props.onActivated()
		end

		setIsExpanded(function(prev)
			return not prev
		end)
	end, { props.onActivated })

	return React.createElement("ImageButton", {
		LayoutOrder = props.layoutOrder,
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		ClipsDescendants = true,

		BackgroundTransparency = 1,
		[React.Event.Activated] = onActivated,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Node = React.createElement("Frame", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = theme.paddingSmall,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}),

			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingSmall,
				PaddingBottom = theme.paddingSmall,
			}),

			Icon = React.createElement(Sprite, {
				image = icon,
				color = iconColor,
				layoutOrder = 1,
				size = UDim2.fromOffset(16, 16),
			}),

			Text = React.createElement("TextLabel", {
				LayoutOrder = 2,
				Text = props.node.label,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = theme.font,
				Size = UDim2.fromScale(1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.text,
				TextSize = theme.textSize,
			}, {
				Flex = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Shrink,
				}),
			}),

			Toggle = if #props.node.children > 0
				then React.createElement("Frame", {
					LayoutOrder = 3,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
				}, {
					RotationWrapper = React.createElement("Frame", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.XY,
						Rotation = if isExpanded then 90 else 0,
					}, {
						Icon = React.createElement(Sprite, {
							image = assets.ChevronRight,
							color = theme.text,
							size = UDim2.fromOffset(16, 16),
						}),
					}),
				})
				else nil,
		}),

		Children = if isExpanded
			then React.createElement("Frame", {
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
			}, {

				Padding = React.createElement("UIPadding", {
					PaddingLeft = theme.padding,
				}),

				Layout = React.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}, children)
			else nil,
	})
end

return TreeNode
