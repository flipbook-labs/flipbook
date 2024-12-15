local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Device = require("./Device")
local devices = require("./devices")
local types = require("./types")

local controls = {
	scaleType = {
		"Physical",
		"Resolution",
		"FitToScreen",
	},
	device = Sift.List.map(devices, function(device)
		return device.name
	end),
	orientation = {
		Enum.ScreenOrientation.Portrait,
		Enum.ScreenOrientation.LandscapeRight,
		Enum.ScreenOrientation.LandscapeLeft,
	},
}

type Props = {
	controls: {
		scaleType: types.DeviceScaleType,
		device: string,
		orientation: Enum.ScreenOrientation,
	},
}

return {
	controls = controls,
	story = function(props: Props)
		local deviceIndex = Sift.List.findWhere(devices, function(other)
			return other.name == props.controls.device
		end)
		assert(deviceIndex, `No device found for {props.controls.device}`)

		return React.createElement(Device, {
			screenScale = 2,
			scaleType = props.controls.scaleType,
			orientation = props.controls.orientation,
			device = devices[deviceIndex],
		})
	end,
}
