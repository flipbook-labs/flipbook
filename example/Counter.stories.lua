local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local constants = require(Example.Parent.constants)
local Counter = require(script.Parent.Counter)

local controls = {
	increment = 1,
	waitTime = 1,
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(props: Props)
	return Roact.createElement(Counter, {
		increment = props.controls.increment,
		waitTime = props.controls.waitTime,
	})
end

return {
	summary = "A simple counter that increments every second",
	controls = controls,
	roact = Roact,
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
