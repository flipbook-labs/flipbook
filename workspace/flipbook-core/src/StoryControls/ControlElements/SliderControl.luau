local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.SliderControl,
	controlValue: number,
	onChanged: (nextValue: number) -> (),
}

local function SliderControl(props: Props)
	return e(Foundation.Slider, {
		label = "",
		onChanged = props.onChanged,
		size = Foundation.Enums.InputSize.Small,
		step = props.controlSchema.step,
		range = props.controlSchema.range,
		value = props.controlValue,
		width = UDim.new(1, 0),
	})
end

return SliderControl
