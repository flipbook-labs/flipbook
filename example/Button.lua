local Roact = require(script.Parent.Parent.Roact)

type Props = {
	text: string,
	onActivated: () -> (),
}

local function Button(props)
	return Roact.createElement("TextButton", {
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundColor3 = Color3.fromRGB(239, 31, 90),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
		[Roact.Event.Activated] = props.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
		}),
	})
end

return Button
