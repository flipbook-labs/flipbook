local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useState = React.useState

export type Props = {
	controlSchema: Storyteller.StringControl,
	controlValue: string,
	onChanged: (nextValue: string) -> (),
}

local function StringControl(props: Props)
	local pendingValue, setPendingValue = useState("" :: string)

	local onSubmit = useCallback(function()
		props.onChanged(pendingValue)
		setPendingValue("")
	end, { props.onChanged })

	return e(Foundation.TextInput, {
		label = "",
		onChanged = setPendingValue,
		onFocusLost = onSubmit,
		onReturnPressed = onSubmit,
		text = props.controlValue,
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return StringControl
