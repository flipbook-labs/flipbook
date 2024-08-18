local React = require("@pkg/React")

local Button = require("./Button")
local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")

local controls = {
	text = "Click me",
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(props: Props)
	return React.createElement(ContextProviders, { plugin = MockPlugin.new() }, {
		Button = React.createElement(Button, {
			text = props.controls.text,
			onClick = function()
				print("click")
			end,
		}),
	})
end

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	stories = stories,
}
