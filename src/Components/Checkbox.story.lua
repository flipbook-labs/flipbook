local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local Checkbox = require(script.Parent.Checkbox)

local function Story(_props, hooks)
	local isChecked, setIsChecked = hooks.useState(false)

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
	}, {
		Checkbox = Roact.createElement(Checkbox, {
			isChecked = isChecked,
			onActivated = setIsChecked,
		}),
	})
end

Story = RoactHooks.new(Roact)(Story)

return {
	roact = Roact,
	story = Roact.createElement(Story),
}
