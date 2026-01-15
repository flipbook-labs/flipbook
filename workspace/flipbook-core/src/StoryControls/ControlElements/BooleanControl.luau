local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
	controlSchema: Storyteller.BooleanControl,
	controlValue: boolean,
	onChanged: (nextValue: boolean) -> (),
}

local function BooleanControl(props: Props)
	local onActivated = useCallback(function()
		props.onChanged(not props.controlValue)
	end, { props.controlValue, props.onChanged } :: { unknown })

	return e(Foundation.Toggle, {
		isChecked = props.controlValue,
		label = "",
		onActivated = onActivated,
		size = Foundation.Enums.InputSize.Small,
	})
end

return BooleanControl
