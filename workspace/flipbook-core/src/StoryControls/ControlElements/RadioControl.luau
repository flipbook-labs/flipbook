local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.RadioControl,
	controlValue: Storyteller.StoryControlValue,
	onChanged: (nextValue: Storyteller.StoryControlValue) -> (),
}

local function RadioControl(props: Props)
	local children: { [string]: React.Node } = {}
	for _, item in props.controlSchema.items do
		local value = if typeof(props.controlSchema.tostring) == "function"
			then props.controlSchema.tostring(item)
			else tostring(item)

		children[tostring(item)] = e(Foundation.RadioGroup.Item, {
			value = value,
		})
	end

	return e(Foundation.RadioGroup.Root, {
		value = tostring(props.controlValue),
		onValueChanged = props.onChanged,
	}, children)
end

return RadioControl
