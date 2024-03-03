local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

export type Props = {
	image: {
		Image: string,
		ImageRectOffset: Vector2,
		ImageRectSize: Vector2,
	},
	transparency: number?,
	layoutOrder: number?,
	size: UDim2?,
	color: Color3?,
}

local function Sprite(props: Props)
	local size = if props.size
		then props.size
		else UDim2.fromOffset(props.image.ImageRectSize.X, props.image.ImageRectSize.Y)

	return React.createElement("ImageLabel", {
		LayoutOrder = props.layoutOrder,
		Image = props.image.Image,
		ImageRectOffset = props.image.ImageRectOffset,
		ImageRectSize = props.image.ImageRectSize,
		ImageTransparency = props.transparency,
		ScaleType = Enum.ScaleType.Slice,
		ImageColor3 = props.color,
		Size = size,
		BackgroundTransparency = 1,
	})
end

return Sprite
