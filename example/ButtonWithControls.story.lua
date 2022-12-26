local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local ButtonWithControls = require(script.Parent.ButtonWithControls)

return {
	summary = "A generic button component that can be used anywhere",
	controls = {
		isDisabled = false,
	},
	story = function(props)
		return Roact.createElement(ButtonWithControls, {
			text = "Click me",
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}
