local flipbook = script:FindFirstAncestor("flipbook")

local Button = require(script.Parent.Button)
local React = require(flipbook.Packages.React)

local controls = {
	text = "Click me",
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(props: Props)
	return React.createElement(Button, {
		text = props.controls.text,
		onClick = function()
			print("click")
		end,
	})
end

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	stories = stories,
}
