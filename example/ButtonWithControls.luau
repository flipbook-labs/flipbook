local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)

export type Props = {
	text: string,
	isDisabled: boolean?,
	onActivated: (() -> ())?,
}

local function ButtonWithControls(props)
	local color = if props.isDisabled then Color3.fromRGB(82, 82, 82) else Color3.fromRGB(239, 31, 90)

	return Roact.createElement("TextButton", {
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
		[Roact.Event.Activated] = if props.isDisabled then nil else props.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return ButtonWithControls
