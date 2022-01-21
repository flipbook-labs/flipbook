local Roact = require(script.Parent.Parent.Roact)

type Props = {
	text: string,
	textSize: number?,
	isBold: boolean?,
}

local function Story(props: Props)
	return Roact.createElement("TextLabel", {
		Text = props.text,
		TextSize = props.textSize or 16,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Font = if props.isBold then Enum.Font.GothamBold else Enum.Font.Gotham,
		Size = UDim2.fromOffset(200, 24),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})
end

return {
	summary = "A story containing multiple sub-stories. The controls apply to every story",
	controls = {
		textSize = 16,
	},
	stories = {
		{
			summary = "The first story",
			story = function(props)
				return Roact.createElement(Story, {
					textSize = props.controls.textSize,
					text = "Hello, World!",
				})
			end,
		},

		{
			summary = "The second story",
			story = function(props)
				return Roact.createElement(Story, {
					textSize = props.controls.textSize,
					text = "HELLO, WORLD!",
					isBold = true,
				})
			end,
		},
	},
}
