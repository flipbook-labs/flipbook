local React = require("@pkg/React")

local Device = require("./Device")
local types = require("./types")

export type Props = {
	screenScale: number,
	scaleType: types.DeviceScaleType,
	devices: { types.Device },
}

local function DeviceList(props: Props)
	local children = {}

	for layoutOrder, device in props.devices do
		children[device.name] = React.createElement(Device, {
			device = device,
			screenScale = props.screenScale,
			scaleType = props.scaleType,
			layoutOrder = layoutOrder,
		})
	end

	return React.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 16),
		}),
	}, children)
end

return DeviceList
