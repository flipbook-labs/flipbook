local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local useTheme = require(flipbook.Hooks.useTheme)
local Sprite = require(flipbook.Components.Sprite)
local types = require(script.Parent.Parent.Parent.Parent.types)

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
	local styles = RoactSpring.useSpring({
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
		[ReactRoblox.Event.MouseEnter] = function()
			setHover(true)
		end,
		[ReactRoblox.Event.MouseLeave] = function()
			setHover(false)
		end,
		[ReactRoblox.Event.Activated] = function()
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
