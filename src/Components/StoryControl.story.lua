local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryControl = require(script.Parent.StoryControl)

local function onValueChange(newValue: any)
	print(newValue, ("(%s)"):format(typeof(newValue)))
end

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
			onValueChange = onValueChange,
		}),

		NumberControl = Roact.createElement(StoryControl, {
			layoutOrder = 2,
			key = "Percent",
			value = 100,
			onValueChange = onValueChange,
		}),

		TextControl = Roact.createElement(StoryControl, {
			layoutOrder = 3,
			key = "Message content",
			value = "Base message",
			onValueChange = onValueChange,
		}),
	}),
}
