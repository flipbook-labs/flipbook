local Roact = require("@pkg/Roact")

local RoactButton = Roact.Component:extend("RoactButton")

function RoactButton:render()
	return Roact.createElement("TextButton", {
		Text = self.props.text,
		TextSize = 16,
		Font = Enum.Font.BuilderSansExtraBold,
		TextColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(200, 40),
		[Roact.Event.Activated] = self.props.onActivated,
	})
end

return RoactButton
