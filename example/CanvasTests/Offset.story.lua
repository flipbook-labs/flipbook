local Example = script:FindFirstAncestor("Example")

local React = require(Example.Parent.Packages.React)
local ReactRoblox = require(Example.Parent.Packages.ReactRoblox)

return {
	summary = "Offset test for the story preview",
	react = React,
	reactRoblox = ReactRoblox,
	story = function()
		return React.createElement("TextLabel", {
			Size = UDim2.fromOffset(2000, 2000),
			AutomaticSize = Enum.AutomaticSize.None,

			TextSize = 24,
			Text = script.Name,
			Font = Enum.Font.GothamBold,
		})
	end,
}
