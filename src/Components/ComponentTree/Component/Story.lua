local flipbook = script:FindFirstAncestor("flipbook")

local assets = require(flipbook.assets)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local types = require(script.Parent.Parent.types)
-- local useDark = require(flipbook.Hooks.useDark)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	active: boolean,
	indent: number,
	node: types.Node,
	onClick: (types.Node) -> (),
}

local function Story(props: Props, hooks: any)
	-- local dark = useDark(hooks)
	local hover, setHover = hooks.useState(false)
	local styles = RoactSpring.useSpring(hooks, {
		alpha = if not props.active then if hover then 0 else 1 else 0,
		color = if not props.active then useTailwind("gray-200") else useTailwind("purple-500"),
		textColor = if not props.active then useTailwind("gray-600") else useTailwind("white"),
		config = constants.SPRING_CONFIG,
	})

	return e("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = styles.color,
		BackgroundTransparency = styles.alpha,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Text = "",
		[Roact.Event.MouseEnter] = function()
			setHover(true)
		end,
		[Roact.Event.MouseLeave] = function()
			setHover(false)
		end,
		[Roact.Event.Activated] = function()
			props.onClick(props.node)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 8 * (props.indent + 1)),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 10),
		}),

		Detail = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 1, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Icon = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = assets.Component,
				ImageColor3 = useTailwind("green-500"),
				LayoutOrder = 0,
				Size = UDim2.fromOffset(16, 16),
			}),

			Typography = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 0),
				Text = props.node.name:sub(1, #props.node.name - 6),
				TextColor3 = styles.textColor,
				TextSize = 14,
			}),
		}),
	})
end

return hook(Story)
