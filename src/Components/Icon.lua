local assets = require(script.Parent.Parent.assets)
local Roact = require(script.Parent.Parent.Packages.Roact)

type Props = {
	anchorPoint: Vector2?,
	color: Color3?,
	icon: string,
	position: UDim2?,
	size: number?,
}

local function Icon(props: Props)
	local icon = assets[props.icon]
	local size = props.size or 16

	return icon
			and Roact.createElement("ImageLabel", {
				AnchorPoint = props.anchorPoint,
				BackgroundTransparency = 1,
				Image = icon,
				ImageColor3 = props.color,
				Position = props.position,
				Size = UDim2.fromOffset(size, size),
			})
		or nil
end

return Icon
