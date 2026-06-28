local Roact = require("@pkg/Roact")

type Props = {
	name: string?,
}

local function HelloWorldLabel(props: Props)
	local name = props.name or "World"

	return Roact.createElement("TextLabel", {
		Text = ("Hello, %s!"):format(name),
		TextSize = 16,
		Font = Enum.Font.BuilderSansExtraBold,
		TextColor3 = Color3.fromRGB(50, 50, 50),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(200, 40),
	})
end

return HelloWorldLabel
