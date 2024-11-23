local React = require("@pkg/react")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
local SelectableTextLabel = require("./SelectableTextLabel")

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
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new() :: any,
		}, {
			SelectableTextLabel = React.createElement(SelectableTextLabel, {
				Text = props.controls.text,
			}),
		})
	end,
}
