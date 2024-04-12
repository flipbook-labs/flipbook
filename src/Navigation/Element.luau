local React = require("@pkg/React")
local useTheme = require("@root/Common/useTheme")

local e = React.createElement

type Props = {
	height: number,
	layoutOrder: number,
	topDivider: boolean?,
	children: any,
}

local function Element(props: Props)
	local theme = useTheme()

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, 0, 0, props.height),
	}, {
		UIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Content = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			Children = React.createElement(React.Fragment, nil, props.children or {}),
		}),

		TopDivider = props.topDivider and e("Frame", {
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			LayoutOrder = 0,
		}),

		Divider = e("Frame", {
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			LayoutOrder = 2,
		}),
	})
end

return Element
