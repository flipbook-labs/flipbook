local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local SelectableTextLabel = require(script.Parent.SelectableTextLabel)

local controls = {
	text = "Ad proident sit nulla incididunt do nisi amet velit velit...",
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "A styled TextLabel with selectable text. Click and drag with the mouse to select content",
	controls = controls,
	story = function(props: Props)
		return React.createElement(SelectableTextLabel, {
			Text = props.controls.text,
		})
	end,
}
