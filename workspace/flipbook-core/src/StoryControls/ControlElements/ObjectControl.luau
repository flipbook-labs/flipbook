local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local InstancePicker = require("@root/Common/InstancePicker")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.ObjectControl?,
	controlValue: Instance?,
	onChanged: (Instance?) -> (),
}

local function ObjectControl(props: Props)
	local currentValue = props.controlValue or (props.controlSchema and props.controlSchema.default)

	return e(InstancePicker, {
		value = currentValue,
		onChanged = props.onChanged,
	})
end

return React.memo(ObjectControl)
