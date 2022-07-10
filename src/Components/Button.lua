local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

local function shift(color: Color3, percent: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v * (1 + percent), 0, 1))
end

local defaultProps = {
	style = "contain",
	text = "Button",
	textSize = 14,
}

type Props = typeof(defaultProps) & {
	text: string,
	style: "contain" | "stroke",

	anchorPoint: Vector2?,
	position: UDim2?,
	layoutOrder: number?,
	endIcon: any?,
	startIcon: any?,

	onClick: (() -> ())?,
}

local function Button(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local hover, setHover = hooks.useState(false)

	return e("ImageButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = if hover then shift(theme.button, 0.2) else theme.button,
		BackgroundTransparency = if props.style == "stroke" then if hover then 0 else 1 else 0,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Position = props.position,
		[Roact.Event.MouseEnter] = function()
			setHover(true)
		end,
		[Roact.Event.MouseLeave] = function()
			setHover(false)
		end,
		[Roact.Event.Activated] = props.onClick,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = theme.paddingSmall,
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = theme.padding,
			PaddingLeft = theme.paddingLarge,
			PaddingRight = theme.paddingLarge,
			PaddingTop = theme.padding,
		}),

		UIStroke = props.style == "stroke" and e("UIStroke", {
			Color = theme.button,
		}),

		EndIcon = props.endIcon,

		StartIcon = props.startIcon,

		UIListLayout = props.startIcon or props.endIcon and e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = theme.paddingSmall,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Text = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.text,
			TextColor3 = if hover then shift(theme.buttonText, 0.2) else theme.buttonText,
			TextSize = props.textSize,
		}),
	})
end

return hook(Button, {
	defaultProps = defaultProps,
})
