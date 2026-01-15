local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement
local useCallback = React.useCallback

export type Props = {
	controlSchema: Storyteller.CheckControl,
	controlValue: { Storyteller.StoryControlValue },
	onChanged: (nextValue: { Storyteller.StoryControlValue }) -> (),
}

local function CheckControl(props: Props)
	local onCheckboxActivated = useCallback(function(item: Storyteller.StoryControlValue)
		local index = table.find(props.controlValue, item)
		local newControlValue = table.clone(props.controlValue)

		if index then
			table.remove(newControlValue, index)
		else
			table.insert(newControlValue, item)
		end

		props.onChanged(newControlValue)
	end, { props.controlValue, props.onChanged } :: { unknown })

	local checkboxes: { [string]: React.Node } = {}
	for index, item in props.controlSchema.items do
		local isChecked = table.find(props.controlSchema.items, item) ~= nil

		checkboxes[`{item}{index}`] = e(Foundation.Checkbox, {
			isChecked = isChecked,
			label = if props.controlSchema.tostring then props.controlSchema.tostring(item) else tostring(item),
			onActivated = function()
				onCheckboxActivated(item)
			end,
		})
	end

	-- TODO: Make this a grid
	return e(Foundation.View, {
		tag = "size-full-y auto-x col gap-small",
	}, checkboxes)
end

return CheckControl
