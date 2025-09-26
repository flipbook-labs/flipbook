local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	story = function()
		return React.createElement("TextLabel", {
			Text = "Orphaned Story",
			TextSize = 24,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
		})
	end,
	packages = {
		React = React,
		ReactRoblox = ReactRoblox,
	},
}
