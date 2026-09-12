local Roact = require("@pkg/Roact")

type Props = {
	name: string?,
}

local function HelloWorld(props: Props)
	local name = props.name or "World"

	return Roact.createElement("TextLabel", {
		Text = ("Hello %s!"):format(name),
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextScaled = true,
		Font = Enum.Font.GothamBold,
		Size = UDim2.fromOffset(200, 100),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
end

return HelloWorld
