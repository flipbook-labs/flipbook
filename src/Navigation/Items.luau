local React = require("@pkg/React")

local e = React.createElement

type Props = {
	layoutOrder: number,
	padding: UDim?,
	children: any,
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

		Children = React.createElement(React.Fragment, nil, props.children or {}),
	})
end

return Items
