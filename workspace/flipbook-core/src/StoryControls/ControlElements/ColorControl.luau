local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local e = React.createElement

export type Props = {
	controlSchema: Storyteller.ColorControl,
	controlValue: Color3,
	onChanged: (nextValue: Color3) -> (),
}

local function ColorControl(props: Props)
	return e(Foundation.ColorPicker, {
		initialColor = props.controlSchema.default,
		availableModes = {
			"Hex",
			"RGB",
		} :: { any },
		onColorChanged = props.onChanged,
	})
end

return ColorControl
