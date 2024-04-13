local Example = script:FindFirstAncestor("Example")

local ButtonWithControls = require(script.Parent.ButtonWithControls)
local Roact = require(Example.Parent.Packages.Roact)

local controls = {
	isDisabled = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	roact = Roact,
	story = function(props: Props)
		return Roact.createElement(ButtonWithControls, {
			text = "Click me",
			isDisabled = props.controls.isDisabled,
			onActivated = function()
				print("click")
			end,
		})
	end,
}
