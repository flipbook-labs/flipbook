local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local styles = require(flipbook.styles)

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
