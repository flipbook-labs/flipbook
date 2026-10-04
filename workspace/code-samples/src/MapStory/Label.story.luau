local React = require("@pkg/React")

return {
	story = function()
		return React.createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Font = Enum.Font.BuilderSansExtraBold,
			Text = "Rendered inside the mapStory wrapper",
			TextColor3 = Color3.fromRGB(50, 50, 50),
			TextSize = 16,
		})
	end,
}
