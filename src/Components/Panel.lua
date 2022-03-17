local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)

export type Props = {
	layoutOrder: number,
}

local function Panel(props: Props)
	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		Position = UDim2.fromOffset(0, 102),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Children = Roact.createFragment(props[Roact.Children]),
	})
end

return hook(Panel)
