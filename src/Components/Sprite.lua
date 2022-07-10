local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)

export type Props = {
	image: {
		Image: string,
		ImageRectOffset: Vector2,
		ImageRectSize: Vector2,
	},
	layoutOrder: number?,
	size: UDim2?,
	color: Color3?,
}

local function Sprite(props: Props)
	local size = if props.size
		then props.size
		else UDim2.fromOffset(props.image.ImageRectSize.X, props.image.ImageRectSize.Y)

	return Roact.createElement("ImageLabel", {
		LayoutOrder = props.layoutOrder,
		Image = props.image.Image,
		ImageRectOffset = props.image.ImageRectOffset,
		ImageRectSize = props.image.ImageRectSize,
		ScaleType = Enum.ScaleType.Slice,
		ImageColor3 = props.color,
		Size = size,
		BackgroundTransparency = 1,
	})
end

return Sprite
