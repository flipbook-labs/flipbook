local React = require("@pkg/React")

local Device = require("./Device")
local types = require("./types")

local function vectorToScreen(vec: Vector2 | Vector3): UDim2
	return UDim2.fromOffset(vec.X, vec.Y)
end

export type Props = {
	screenScale: number,
	scaleType: types.DeviceScaleType,
	devices: { types.Device },
}

local function DeviceList(props: Props)
	local children = {}

	for layoutOrder, device in props.devices do
		local size: UDim2
		if props.scaleType == "FitToScreen" then
			size = UDim2.fromScale(1, 1)
		elseif props.scaleType == "Resolution" then
			size = vectorToScreen(device.resolution)
		elseif props.scaleType == "Physical" then
			size = vectorToScreen(device.physicalSize * props.screenScale)
		end

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
