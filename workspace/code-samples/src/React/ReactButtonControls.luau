local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local function ReactButton(props: {
	text: string,
	isDisabled: boolean,
	onActivated: () -> (),
})
	return React.createElement("TextButton", {
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.BuilderSansExtraBold,
		TextColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = if props.isDisabled then false else true,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(200, 40),
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

return ReactButton
