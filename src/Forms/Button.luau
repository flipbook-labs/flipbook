local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local useTheme = require("@root/Common/useTheme")

local e = React.createElement

local function shift(color: Color3, percent: number): Color3
	local h, s, v = color:ToHSV()
	return Color3.fromHSV(h, s, math.clamp(v * (1 + percent), 0, 1))
end

type Style = "contain" | "stroke"

local defaultProps = {
	style = "contain" :: Style,
	text = "Button",
}

type Props = {
	text: string,
	style: Style?,

	anchorPoint: Vector2?,
	position: UDim2?,
	layoutOrder: number?,
	endIcon: any?,
	startIcon: any?,
	textColor: Color3?,
	backgroundColor: Color3?,

	onClick: (() -> ())?,
}

type InternalProps = Props & typeof(defaultProps)

local function Button(providedProps: Props)
	local theme = useTheme()

	local props: InternalProps = Sift.Dictionary.join(defaultProps, {
		backgroundColor = theme.button,
		textColor = theme.buttonText,
	}, providedProps)

	local hover, setHover = React.useState(false)

	return e("ImageButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = if hover then shift(props.backgroundColor, 0.2) else props.backgroundColor,
		BackgroundTransparency = if props.style == "stroke" then if hover then 0 else 1 else 0,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Position = props.position,
		[React.Event.MouseEnter] = function()
			setHover(true)
		end,
		[React.Event.MouseLeave] = function()
			setHover(false)
		end,
		[React.Event.Activated] = props.onClick :: any,
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
			Font = theme.buttonFont,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.text,
			TextColor3 = if hover then shift(props.textColor, 0.2) else props.textColor,
			TextSize = theme.buttonTextSize,
		}),
	})
end

return Button
