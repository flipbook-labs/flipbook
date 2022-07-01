local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	active: boolean,
	layoutOrder: number,
	onClick: () -> (),
	text: string,
}

local function ButtonLink(props: Props, hooks: any)
	local hover, setHover = hooks.useState(false)
	local styles = RoactSpring.useSpring(hooks, {
		alpha = if not props.active and hover then 0 else 1,
		textColor = if props.active then useTailwind("gray-800") else useTailwind("gray-600"),
		config = constants.SPRING_CONFIG,
	})

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = styles.alpha,
		BackgroundColor3 = useTailwind("gray-100"),
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 0),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		}),

		Text = e("TextButton", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = useTailwind("gray-100"),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			LayoutOrder = props.layoutOrder,
			Size = UDim2.fromScale(0, 0),
			Text = props.text,
			TextColor3 = styles.textColor,
			TextSize = 14,
			[Roact.Event.MouseEnter] = function()
				setHover(true)
			end,
			[Roact.Event.MouseLeave] = function()
				setHover(false)
			end,
			[Roact.Event.Activated] = props.onClick,
		}),
	})
end

return hook(ButtonLink)
