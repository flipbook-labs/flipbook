local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	height: number,
	layoutOrder: number,
	topDivider: boolean?,
}

local function Element(props: Props, hooks: any)
	local theme = useTheme(hooks)

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
			Children = Roact.createFragment(props[Roact.Children] or {}),
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

return hook(Element)
