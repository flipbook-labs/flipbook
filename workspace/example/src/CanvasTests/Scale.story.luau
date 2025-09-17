local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

return {
	summary = "Scale test for the story preview",
	react = React,
	reactRoblox = ReactRoblox,
	story = function()
		return React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			AutomaticSize = Enum.AutomaticSize.None,

			TextSize = 24,
			Text = script.Name,
			Font = Enum.Font.GothamBold,
		})
	end,
}
