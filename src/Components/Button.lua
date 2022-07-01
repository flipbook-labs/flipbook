local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)

local e = Roact.createElement

type Props = {
	anchorPoint: Vector2?,
	color: Color3,
	endIcon: any?,
	highlight: { base: Color3?, text: Color3? }?,
	layoutOrder: number?,
	onClick: () -> ()?,
	padding: { x: number, y: number },
	position: UDim2?,
	startIcon: any?,
	style: "contain" | "stroke",
	text: string,
	textColor: Color3,
	textSize: number,
}

local function Button(props: Props, hooks: any)
	local hover, setHover = hooks.useState(false)

	local paddingX = UDim.new(0, props.padding.x)
	local paddingY = UDim.new(0, props.padding.y)

	return e("ImageButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = props.anchorPoint,
		BackgroundColor3 = if props.highlight and props.highlight.base
			then if hover then props.highlight.base else props.color
			else props.color,
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
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = paddingY,
			PaddingLeft = paddingX,
			PaddingRight = paddingX,
			PaddingTop = paddingY,
		}),

		UIStroke = if props.style == "stroke"
			then e("UIStroke", {
				Color = props.color,
			})
			else nil,

		EndIcon = if props.endIcon then props.endIcon else nil,
		StartIcon = if props.startIcon then props.startIcon else nil,

		UIListLayout = if props.startIcon or props.endIcon
			then e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			})
			else nil,

		Text = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0, 0),
			Text = props.text,
			TextColor3 = if props.highlight and props.highlight.text
				then if hover then props.highlight.text else props.textColor
				else props.textColor,
			TextSize = props.textSize,
		}),
	})
end

return hook(Button, {
	defaultProps = {
		color = Color3.fromHex("1F2937"),
		highlight = {
			base = Color3.fromHex("374151"),
		},
		layoutOrder = 0,
		padding = { x = 20, y = 10 },
		style = "contain",
		text = "Button",
		textColor = Color3.new(1, 1, 1),
		textSize = 14,
	},
})
