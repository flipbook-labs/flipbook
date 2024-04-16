local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local constants = require(Example.Parent.constants)
local Button = require(script.Parent.Button)

local stories = {}

stories.Primary = Roact.createElement(Button, {
	text = "Click me",
	onActivated = function()
		print("click")
	end,
})

return {
	summary = "A generic button component that can be used anywhere",
	roact = Roact,
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
