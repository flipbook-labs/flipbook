local React = require("@pkg/React")

local function ReactButtonTypedControls(props: {
	text: string,
	fontSize: number,
	textColor: Color3,
	isDisabled: boolean,
	size: string,
	onActivated: () -> (),
})
	local sizeMap = {
		Small = UDim2.fromOffset(120, 32),
		Medium = UDim2.fromOffset(200, 40),
		Large = UDim2.fromOffset(280, 48),
	}

	return React.createElement("TextButton", {
		Text = props.text,
		TextSize = props.fontSize,
		Font = Enum.Font.BuilderSansExtraBold,
		TextColor3 = props.textColor,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = not props.isDisabled,
		BorderSizePixel = 0,
		Size = sizeMap[props.size] or sizeMap.Medium,
		[React.Event.Activated] = if props.isDisabled then nil else props.onActivated,
	}, {
		Overlay = if props.isDisabled
			then React.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.6,
			})
			else nil,
	})
end

return ReactButtonTypedControls
