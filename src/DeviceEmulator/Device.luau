local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local types = require("./types")

local MM_PER_INCH = 1 / 25.4

local function vectorToScreen(vec: Vector2 | Vector3): UDim2
	return UDim2.fromOffset(vec.X, vec.Y)
end

export type Props = {
	screenScale: number,
	scaleType: types.DeviceScaleType,
	device: types.Device,
	orientation: Enum.ScreenOrientation?,
	layoutOrder: number?,
}

local defaultProps = {
	screenScale = 1,
	orientation = Enum.ScreenOrientation.Portrait,
}

type InternalProps = typeof(defaultProps) & Props

local function DeviceList(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.join(defaultProps, providedProps)

	local screenSizeMm = props.device.resolution / (props.device.ppi * MM_PER_INCH)
	local deviceFrameSizeMm = props.device.physicalSize - screenSizeMm
	local deviceFrameSize = vectorToScreen(deviceFrameSizeMm)

	local screenSize: UDim2
	if props.scaleType == "FitToScreen" then
		screenSize = UDim2.fromScale(1, 1)
	elseif props.scaleType == "Resolution" then
		screenSize = vectorToScreen(props.device.resolution)
	elseif props.scaleType == "Physical" then
		screenSize = vectorToScreen(props.device.physicalSize * props.screenScale)
	end

	local aspectRatio = if props.orientation == Enum.ScreenOrientation.Portrait
		then props.device.resolution.X / props.device.resolution.Y
		else props.device.resolution.Y / props.device.resolution.X

	local rotation = 0
	if props.orientation == Enum.ScreenOrientation.LandscapeLeft then
		rotation = 90
	elseif props.orientation == Enum.ScreenOrientation.LandscapeRight then
		rotation = -90
	end

	return React.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		BackgroundTransparency = 1,
		Size = if props.scaleType == "FitToScreen" then UDim2.fromScale(1, 1) else nil,
		AutomaticSize = Enum.AutomaticSize.XY,
		Rotation = rotation,
	}, {
		AspectRatio = if props.scaleType == "FitToScreen"
			then React.createElement("UIAspectRatioConstraint", {
				AspectRatio = aspectRatio,
			})
			else nil,

		Scale = React.createElement("UIScale", {
			Scale = props.screenScale,
		}),

		DeviceFrame = React.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = props.device.frame.Image,
			ImageRectOffset = props.device.frame.ImageRectOffset,
			ImageRectSize = props.device.frame.ImageRectSize,
			Size = screenSize + deviceFrameSize,
		}, {
			Layout = React.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			ScreenFrame = React.createElement("Frame", {
				Size = screenSize,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			}, {
				Corner = React.createElement("UICorner", {
					CornerRadius = UDim.new(0.1, 0),
				}),

				Text = React.createElement("TextLabel", {
					Text = "Esse minim reprehenderit et enim esse labore quis irure id deserunt dolor sint. Minim laboris eu excepteur reprehenderit laboris commodo eu sit ipsum dolor. Elit reprehenderit laboris eu mollit nostrud ut irure et laborum incididunt. Cillum adipisicing Lorem cillum aliquip dolore sunt sint ex quis cillum officia.",
					TextWrapped = true,
					Font = Enum.Font.BuilderSansMedium,
					TextSize = 16,
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.XY,
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}),
			}),
		}),
	})
end

return DeviceList
