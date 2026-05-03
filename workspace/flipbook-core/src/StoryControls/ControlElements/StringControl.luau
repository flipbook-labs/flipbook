local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

export type Props = {
	controlSchema: Storyteller.StringControl,
	controlValue: string?,
	onChanged: (nextValue: string) -> (),
}

local function StringControl(props: Props)
	local pendingValue, setPendingValue = useState(props.controlValue or "" :: string)

	useEffect(function()
		setPendingValue(props.controlValue or "")
	end, { props.controlValue } :: { unknown })

	local onSubmit = useCallback(function()
		props.onChanged(pendingValue)
	end, { props.onChanged, pendingValue } :: { unknown })

	return e(Foundation.TextInput, {
		label = "",
		onChanged = setPendingValue,
		onFocusLost = onSubmit,
		onReturnPressed = onSubmit,
		text = if props.controlValue then props.controlValue else "",
		placeholder = "Enter text...",
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return React.memo(StringControl)
