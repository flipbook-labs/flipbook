local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local RoactSpring = require(flipbook.Packages.RoactSpring)
local constants = require(flipbook.constants)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	active: boolean,
	layoutOrder: number,
	onClick: () -> (),
	text: string,
}

local function ButtonLink(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local hover, setHover = hooks.useState(false)
	local styles = RoactSpring.useSpring(hooks, {
		alpha = if not props.active and hover then 0 else 1,
		textColor = if props.active then theme.text else theme.textFaded,
		config = constants.SPRING_CONFIG,
	})

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = styles.alpha,
		BackgroundColor3 = theme.button,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 0),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
			PaddingRight = theme.padding,
			PaddingTop = theme.padding,
		}),

		Text = e("TextButton", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.button,
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
