local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local useTheme = require(flipbook.Common.useTheme)
local Sprite = require(flipbook.Common.Sprite)
local types = require(flipbook.Explorer.types)

local e = React.createElement

type Props = {
	expanded: boolean,
	hasChildren: boolean,
	indent: number,
	node: types.ComponentTreeNode,
	onClick: (types.ComponentTreeNode) -> (),
}

local function Directory(props: Props)
	local theme = useTheme()
	local hover, setHover = React.useState(false)
	local styles = (RoactSpring.useSpring :: any)({
		alpha = if hover then 0 else 1,
		rotation = if props.expanded then 90 else 0,
		config = constants.SPRING_CONFIG,
	})

	return e("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.divider,
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
				layoutOrder = 0,
				image = if props.node.icon == "folder" then assets.Folder else assets.Storybook,
				color = if props.node.icon == "folder" then theme.directory else theme.textFaded,
				size = UDim2.fromOffset(16, 16),
			}),

			Typography = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.font,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 0),
				-- TODO: Do string parsing to get rid of `.storybook`
				Text = props.node.name,
				TextColor3 = theme.textFaded,
				TextSize = theme.textSize,
			}),
		}),

		ChevronWrapper = e("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(1, 0.5),
			Rotation = styles.rotation,
			Size = UDim2.fromOffset(16, 16),
		}, {
			Chevron = e(Sprite, {
				image = assets.ChevronRight,
				color = theme.text,
				size = UDim2.fromScale(1, 1),
			}),
		}),
	})
end

return Directory
