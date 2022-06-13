local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	padding: UDim,
}

local function Items(props: Props)
	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = props.padding,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Children = Roact.createFragment(props[Roact.Children] or {}),
	})
end

return hook(Items)
