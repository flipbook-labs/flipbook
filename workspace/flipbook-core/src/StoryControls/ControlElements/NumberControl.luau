local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.NumberControl,
	controlValue: number,
	onChanged: (nextValue: number) -> (),
}

local function NumberControl(props: Props)
	return e(Foundation.NumberInput, {
		label = "",
		onChanged = props.onChanged,
		size = Foundation.Enums.InputSize.Small,
		step = props.controlSchema.step,
		value = props.controlValue,
		width = UDim.new(1, 0),
	})
end

return NumberControl
