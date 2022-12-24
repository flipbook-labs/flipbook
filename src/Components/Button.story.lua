local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local Button = require(script.Parent.Button)

local controls = {
	text = "Click me",
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	story = function(props: Props)
		return Roact.createElement(Button, {
			text = props.controls.text,
			onClick = function()
				print("click")
			end,
		})
	end,
}
