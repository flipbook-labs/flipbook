local React = require("@pkg/React")

local DeviceList = require("./DeviceList")
local devices = require("./devices")
local types = require("./types")

local controls = {
	scaleType = {
		"Physical",
		"Resolution",
		"FitToScreen",
	},
}
type Props = {
	controls: {
		scaleType: types.DeviceScaleType,
	},
}

return {
	controls = controls,
	story = function(props: Props)
		return React.createElement(DeviceList, {
			screenScale = 1.5,
			scaleType = props.controls.scaleType,
			devices = devices,
		})
	end,
}
