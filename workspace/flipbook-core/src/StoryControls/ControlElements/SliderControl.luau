local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

local useBinding = React.useBinding
local useCallback = React.useCallback

export type Props = {
	controlSchema: Storyteller.SliderControl,
	controlValue: number,
	onChanged: (nextValue: number) -> (),
}

local function SliderControl(props: Props)
	local value, setValue = useBinding(props.controlValue)

	local onValueChanged = useCallback(function(newValue)
		setValue(newValue)
		props.onChanged(newValue)
	end, { props.onChanged })

	return e(Foundation.Slider, {
		label = "",
		onValueChanged = onValueChanged,
		size = Foundation.Enums.InputSize.Small,
		step = props.controlSchema.step,
		range = props.controlSchema.range,
		value = value,
		width = UDim.new(1, 0),
	})
end

return SliderControl
