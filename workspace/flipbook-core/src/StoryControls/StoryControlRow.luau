local Foundation = require("@rbxpkg/Foundation")
local LuauPolyfill = require("@pkg/LuauPolyfill")
local React = require("@pkg/React")

local ControlType = require("@root/StoryControls/Enums/ControlType")
local types = require("@root/StoryControls/types")

type StoryControl = types.StoryControl

local e = React.createElement
local useCallback = React.useCallback

local Array = LuauPolyfill.Array

export type Props = {
	control: StoryControl,
	LayoutOrder: number?,
}

local function StoryControlRow(props: Props)
	local setControl = useCallback(function(newValue: any)
		local newValueAsNumber = tonumber(newValue)

		if newValueAsNumber ~= nil then
			newValue = newValueAsNumber
		end

		props.setControl(props.control.key, newValue)
	end, {})

	local controlType = props.control.control

	print("controlType", controlType)

	local controlElement: React.Node
	if controlType == ControlType.Boolean then
		controlElement = e(Foundation.Checkbox, {
			isChecked = props.control.value,
			label = "",
			onActivated = setControl,
			size = Foundation.Enums.InputSize.Small,
		})
	elseif controlType == ControlType.Number then
		controlElement = e(Foundation.NumberInput, {
			label = "",
			onChanged = setControl,
			size = Foundation.Enums.InputSize.Small,
			step = 1,
			value = props.control.value,
			width = UDim.new(1, 0),
		})
	elseif controlType == ControlType.String then
		controlElement = e(Foundation.TextInput, {
			label = "",
			onChanged = function(newText)
				setPendingControl(newText)
			end,
			onFocusLost = function()
				setControl(pendingControl)
			end,
			onReturnPressed = function()
				setControl(pendingControl)
			end,
			text = props.control.value,
			size = Foundation.Enums.InputSize.Small,
			width = UDim.new(1, 0),
		})
	elseif controlType == ControlType.Check then
	elseif controlType == ControlType.Color then
	elseif controlType == ControlType.Date then
	elseif controlType == ControlType.MultiSelect then
	elseif controlType == ControlType.Radio then
	elseif controlType == ControlType.Select then
		local changedValue = props.controls[props.control.key]
		local controlItems = Array.map(props.control.value, function(value): Foundation.DropdownItem
			return {
				id = value,
				text = tostring(value),
			}
		end)

		controlElement = e(Foundation.Dropdown.Root, {
			items = controlItems,
			label = "",
			onItemChanged = setControl,
			size = Foundation.Enums.InputSize.Small,
			value = if changedValue ~= nil then changedValue else props.control.value[1],
			width = UDim.new(1, 0),
		})
	elseif controlType == ControlType.Slider then
	end

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col size-full-0",
	}, {
		Content = e(Foundation.View, {
			LayoutOrder = 1,
			tag = "align-y-center auto-y gap-medium padding-medium row size-full-0",
		}, {
			Title = e(Foundation.Text, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.2, 0),
				Text = props.control.key,
				tag = "auto-y text-align-x-left text-label-medium",
			}),

			Option = e(Foundation.View, {
				LayoutOrder = 2,
				tag = "align-x-left auto-y fill row",
			}, {
				-- Keying by the identity of sortedControls fixes a bug where
				-- the options visually do not update when two stories have the
				-- exact same controls.
				[`Option_{props.control}`] = controlElement,
			}),
		}),
	})
end

return StoryControlRow
