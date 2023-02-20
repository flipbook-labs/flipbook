local Example = script:FindFirstAncestor("Example")

local React = require(Example.Parent.Packages.React)
local ReactRoblox = require(Example.Parent.Packages.ReactRoblox)

return {
	summary = "AutoamticSize test using a height that exceeds the story preview",
	react = React,
	reactRoblox = ReactRoblox,
	story = function()
		return React.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,

			TextSize = 24,
			Text = script.Name .. string.rep("\nLine", 100),
			Font = Enum.Font.GothamBold,
		})
	end,
}
