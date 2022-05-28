local assets = require(script.Parent.Parent.assets)
local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)

type Props = {
	anchorPoint: Vector2,
	color: Color3,
	icon: string,
	position: Vector2,
	rotation: number?,
	size: UDim2 | number,
}

local function reconcileSize(size: UDim2 | number): UDim2?
	if typeof(size) == "UDim2" then
		return size
	elseif typeof(size) == "number" then
		return UDim2.fromOffset(size, size)
	end
	return nil
end

local function Icon(props: Props)
	return Roact.createElement(
		"ImageLabel",
		Llama.Dictionary.join(styles.Icon, {
			AnchorPoint = props.anchorPoint,
			Image = assets[props.icon],
			ImageColor3 = props.color,
			Position = props.position,
			Rotation = props.rotation,
			Size = reconcileSize(props.size),
		})
	)
end

return Icon
