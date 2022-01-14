local hook = require(script.Parent.Parent.hook)
local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local PADDING = UDim.new(0, 9)
local NO_PADDING = UDim.new(0, 0)

type Props = {
	position: UDim2?,
}

local function Searchbar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = props.position,
		Size = UDim2.fromOffset(200, 32),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingLeft = PADDING,
			PaddingRight = PADDING,
			PaddingTop = NO_PADDING,
			PaddingBottom = NO_PADDING,
		}),

		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = theme.stroke,
		}),

		Icon = Roact.createElement(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			color = theme.stroke,
			icon = "magnifying-glass",
			position = UDim2.fromScale(0, 0.5),
			size = 14,
		}),

		Divider = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = theme.stroke,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 23, 0.5, 0),
			Size = UDim2.new(0, 1, 1, -8),
		}),

		DeselectedText = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 32, 0.5, 0),
			Text = "Find components",
			TextColor3 = theme.stroke,
			TextSize = 10,
		}),
	})
end

return hook(Searchbar)
