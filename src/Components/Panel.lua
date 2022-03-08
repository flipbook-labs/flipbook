local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)

export type Props = {
	layoutOrder: number,
}

local function Panel(props: any)
	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		Position = UDim2.fromOffset(0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.LARGE_PADDING,
			PaddingRight = UDim.new(0, 0),
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
		}),

		Children = Roact.createFragment(props[Roact.Children]),
	})
end

return RoactHooks.new(Roact)(Panel)
