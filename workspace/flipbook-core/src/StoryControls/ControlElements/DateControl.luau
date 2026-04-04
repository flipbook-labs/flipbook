local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.DateControl,
	controlValue: DateTime,
	onChanged: (nextValue: DateTime) -> (),
}

local function DateControl(props: Props)
	return e(Foundation.DateTimePicker, {
		label = "",
		defaultDates = props.controlValue,
		onChanged = function(startDateTime: DateTime?, _endDateTime: DateTime?)
			if startDateTime then
				props.onChanged(startDateTime)
			end
		end,
	})
end

return DateControl
