local React = require("@pkg/react")
local ReactSpring = require("@pkg/react-spring")
local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local constants = require("@root/constants")
local types = require("@root/Explorer/types")
local useTheme = require("@root/Common/useTheme")

local e = React.createElement

type Props = {
	active: boolean,
	indent: number,
	node: types.ComponentTreeNode,
	onClick: (types.ComponentTreeNode) -> (),
}

local function Story(props: Props)
	local theme = useTheme()
	local hover, setHover = React.useState(false)
	local styles = (ReactSpring.useSpring :: any)({
		alpha = if not props.active then if hover then 0 else 1 else 0,
		color = if not props.active then theme.divider else theme.selection,
		textColor = if not props.active then theme.textFaded else theme.background,
		config = constants.SPRING_CONFIG,
	})

	return e("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = styles.color,
		BackgroundTransparency = styles.alpha,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Text = "",
		[React.Event.MouseEnter] = function()
			setHover(true)
		end,
		[React.Event.MouseLeave] = function()
			setHover(false)
		end,
		[React.Event.Activated] = function()
			props.onClick(props.node)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = theme.corner,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.paddingSmall + UDim.new(0, theme.padding.Offset * props.indent),
			PaddingRight = theme.paddingSmall,
			PaddingTop = theme.padding,
		}),

		Detail = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 1, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = theme.paddingSmall,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Icon = e(Sprite, {
				image = assets.Component,
				color = theme.story,
				layoutOrder = 0,
				size = UDim2.fromOffset(16, 16),
			}),

			Typography = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 0),
				Text = props.node.name:sub(1, #props.node.name - 6),
				TextColor3 = theme.text,
				TextSize = theme.textSize,
			}),
		}),
	})
end

return Story
