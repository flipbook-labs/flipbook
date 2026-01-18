local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
	controlSchema: Storyteller.RadioControl,
	controlValue: Storyteller.StoryControlValue,
	onChanged: (nextValue: Storyteller.StoryControlValue) -> (),
}

local function toRadioValue(schema: Storyteller.RadioControl, value: Storyteller.StoryControlValue): string
	return if typeof(schema.tostring) == "function" then schema.tostring(value) else tostring(value)
end

local function RadioControl(props: Props)
	local onValueChanged = useCallback(function(newValue: string)
		for _, item in props.controlSchema.items do
			if newValue == toRadioValue(props.controlSchema, item) then
				props.onChanged(item)
				return
			end
		end
	end, { props.onChanged, props.controlSchema } :: { unknown })

	local children: { [string]: React.Node } = {}
	for _, item in props.controlSchema.items do
		children[tostring(item)] = e(Foundation.RadioGroup.Item, {
			value = toRadioValue(props.controlSchema, item),
		})
	end

	return e(Foundation.RadioGroup.Root, {
		value = toRadioValue(props.controlSchema, props.controlValue),
		onValueChanged = onValueChanged,
	}, children)
end

return RadioControl
