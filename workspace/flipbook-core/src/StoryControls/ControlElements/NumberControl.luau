local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useRef = React.useRef
local useState = React.useState

export type Props = {
	controlSchema: Storyteller.NumberControl,
	controlValue: number,
	onChanged: (nextValue: number) -> (),
}

local function NumberControl(props: Props)
	local isFocused, setIsFocused = useState(false)
	local pending, setPending = useState(props.controlValue)
	local pendingRef = useRef(props.controlValue)

	local onChanged = useCallback(function(value: number)
		if isFocused then
			pendingRef.current = value
			setPending(value)
		else
			props.onChanged(value)
		end
	end, { isFocused, props.onChanged } :: { unknown })

	local onFocusGained = useCallback(function()
		pendingRef.current = props.controlValue
		setPending(props.controlValue)
		setIsFocused(true)
	end, { props.controlValue } :: { unknown })

	local onFocusLost = useCallback(function()
		setIsFocused(false)
		props.onChanged(pendingRef.current)
	end, { props.onChanged } :: { unknown })

	return e(Foundation.NumberInput, {
		label = "",
		onChanged = onChanged,
		onFocusGained = onFocusGained,
		onFocusLost = onFocusLost,
		step = props.controlSchema.step,
		value = if isFocused then pending else props.controlValue,
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return React.memo(NumberControl)
