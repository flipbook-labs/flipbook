local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryControl = require(script.Parent.StoryControl)

return {
	summary = "Several of these components get created based off the controls specified for a story",
	story = Roact.createFragment({
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 16),
		}),

		CheckboxControl = Roact.createElement(StoryControl, {
			layoutOrder = 1,
			key = "Is Checked",
			value = false,
		}),

		NumberControl = Roact.createElement(StoryControl, {
			layoutOrder = 2,
			key = "Percent",
			value = 100,
		}),

		TextControl = Roact.createElement(StoryControl, {
			layoutOrder = 3,
			key = "Message content",
			value = "Base message",
		}),
	}),
}
