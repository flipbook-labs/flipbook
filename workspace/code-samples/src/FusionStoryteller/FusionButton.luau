local Fusion = require("@pkg/Fusion")

local New = Fusion.New
local OnEvent = Fusion.OnEvent

local function FusionButton(props: {
	text: string,
	onActivated: () -> (),
})
	return New("TextButton")({
		Text = props.text,
		TextSize = 16,
		Font = Enum.Font.BuilderSansExtraBold,
		TextColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(200, 40),
		[OnEvent("Activated")] = props.onActivated,
	})
end

return FusionButton
