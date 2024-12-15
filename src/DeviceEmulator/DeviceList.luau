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
		children[device.name] = React.createElement("Frame", {
			LayoutOrder = layoutOrder,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 16),
			}),

			DeviceName = React.createElement("TextLabel", {
				Text = device.name,
				Font = Enum.Font.BuilderSansBold,
				TextSize = 24,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),

			Device = React.createElement(Device, {
				device = device,
				screenScale = props.screenScale,
				scaleType = props.scaleType,
				layoutOrder = 2,
			}),
		})
	end

	return React.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 24),
		}),
	}, children)
end

return DeviceList
