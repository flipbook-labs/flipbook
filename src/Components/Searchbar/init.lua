local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)
local Sprite = require(flipbook.Components.Sprite)

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
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
			PaddingRight = theme.padding,
			PaddingTop = theme.padding,
		}),

		UIStroke = e("UIStroke", {
			Color = theme.divider,
		}),

		Icon = e(Sprite, {
			image = assets.Search,
			color = theme.divider,
			size = UDim2.fromOffset(16, 16),
		}),
	})
end

return hook(Searchbar)
