local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.StringControl,
	controlValue: string?,
	onChanged: (nextValue: string) -> (),
}

local function StringControl(props: Props)
	return e(Foundation.TextInput, {
		label = "",
		onChanged = props.onChanged,
		text = if props.controlValue then props.controlValue else "",
		placeholder = "Enter text...",
		size = Foundation.Enums.InputSize.XSmall,
		width = UDim.new(1, 0),
	})
end

return React.memo(StringControl)
