--!nocheck
local UIBloxRoot = script.Parent.Parent.Parent.Parent
local Packages = UIBloxRoot.Parent

local Roact = require(Packages.Roact)
local withStyle = require(UIBloxRoot.Core.Style.withStyle)

local ImageSetComponent = require(UIBloxRoot.Core.ImageSet.ImageSetComponent)
local Images = require(UIBloxRoot.App.ImageSet.Images)
local AnimatedGradient = require(script.Parent.AnimatedGradient)

local INSET_ADJUSTMENT = 2
local PADDING = 50
local ASSET_NAME = "component_assets/square_7_stroke_3"

export type Props = {
	cursorRef: table,
	isVisible: boolean,
}

return function(props: Props)
	return withStyle(function(style)
		return Roact.createElement(ImageSetComponent.Label, {
			Image = Images[ASSET_NAME],
			ImageColor3 = style.Theme.SelectionCursor.AnimatedColor,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, INSET_ADJUSTMENT * 2 + PADDING, 1, INSET_ADJUSTMENT * 2),
			Position = UDim2.fromOffset(-INSET_ADJUSTMENT - PADDING / 2, -INSET_ADJUSTMENT),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(3.5, 3.5, 3.5, 3.5),

			[Roact.Ref] = props.cursorRef,
		}, {
			AnimatedGradient = props.isVisible and Roact.createElement(AnimatedGradient) or nil,
		})
	end)
end
