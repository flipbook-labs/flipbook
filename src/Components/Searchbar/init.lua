local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	layoutOrder: number?,
}

local function Searchbar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		BackgroundColor3 = theme.background,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromOffset(236, 36),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		}),

		UIStroke = e("UIStroke", {
			Color = theme.divider,
		}),

		Icon = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = assets.Search,
			Size = UDim2.fromOffset(16, 16),
			ImageColor3 = theme.divider,
		}),
	})
end

return hook(Searchbar)
