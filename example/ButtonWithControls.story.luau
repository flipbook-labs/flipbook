local Example = script:FindFirstAncestor("Example")

local Roact = require(Example.Parent.Packages.Roact)
local constants = require(Example.Parent.constants)
local ButtonWithControls = require(script.Parent.ButtonWithControls)

local controls = {
	isDisabled = false,
}

type Props = {
	controls: typeof(controls),
}

local stories = {}

stories.Primary = function(props: Props)
	return Roact.createElement(ButtonWithControls, {
		text = "Click me",
		isDisabled = props.controls.isDisabled,
		onActivated = function()
			print("click")
		end,
	})
end

return {
	summary = "A generic button component that can be used anywhere",
	controls = controls,
	roact = Roact,
	story = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then nil else stories.Primary,
	stories = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then stories else nil,
}
