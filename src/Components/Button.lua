local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local Sift = require(flipbook.Packages.Sift)
local useTheme = require(flipbook.Hooks.useTheme)

local e = React.createElement

local function shift(color: Color3, percent: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v * (1 + percent), 0, 1))
end

local defaultProps = {
	style = "contain",
	text = "Button",
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

local function Button(props: Props)
	props = Sift.Dictionary.join(defaultProps, props)

	local theme = useTheme()
	local hover, setHover = React.useState(false)

	return e("ImageButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = if hover then shift(theme.button, 0.2) else theme.button,
		BackgroundTransparency = if props.style == "stroke" then if hover then 0 else 1 else 0,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Position = props.position,
		[ReactRoblox.Event.MouseEnter] = function()
			setHover(true)
		end,
		[ReactRoblox.Event.MouseLeave] = function()
			setHover(false)
		end,
		[ReactRoblox.Event.Activated] = props.onClick,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = theme.corner,
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
			Font = theme.font,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.text,
			TextColor3 = if hover then shift(theme.buttonText, 0.2) else theme.buttonText,
			TextSize = theme.textSize,
		}),
	})
end

return Button
