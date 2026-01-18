local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback
local useMemo = React.useMemo

export type Props = {
	controlSchema: Storyteller.MultiSelectControl,
	controlValue: { Storyteller.StoryControlValue },
	onChanged: (nextValue: { Storyteller.StoryControlValue }) -> (),
}

local function MultiSelectControl(props: Props)
	local controlItems = useMemo(function()
		return Sift.List.map(props.controlSchema.items, function(value): Foundation.DropdownItem
			local isChecked = table.find(props.controlValue, value) ~= nil

			return {
				id = tostring(value),
				text = if typeof(props.controlSchema.tostring) == "function"
					then props.controlSchema.tostring(value)
					else tostring(value),
				isChecked = isChecked,
			}
		end)
	end, { props.controlSchema, props.controlValue } :: { unknown })

	local onItemChanged = useCallback(function() end, {})

	return e(Foundation.Dropdown.Root, {
		items = controlItems,
		label = "",
		onItemChanged = onItemChanged,
		value = tostring(props.controlValue),
		size = Foundation.Enums.InputSize.Small,
		width = UDim.new(1, 0),
	})
end

return MultiSelectControl
