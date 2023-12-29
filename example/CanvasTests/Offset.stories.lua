local Example = script:FindFirstAncestor("Example")

local React = require(Example.Parent.Packages.React)
local ReactRoblox = require(Example.Parent.Packages.ReactRoblox)
local constants = require(Example.Parent.constants)

local stories = {}

stories.Primary = function()
	return React.createElement("TextLabel", {
		Size = UDim2.fromOffset(2000, 2000),
		AutomaticSize = Enum.AutomaticSize.None,

		TextSize = 24,
		Text = script.Name,
		Font = Enum.Font.GothamBold,
	})
end

return {
	summary = "Offset test for the story preview",
	react = React,
	reactRoblox = ReactRoblox,
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
