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

local function Branding(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.padding,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = -theme.paddingSmall,
		}),

		Icon = e(Sprite, {
			layoutOrder = 0,
			image = assets.IconLight,
			size = UDim2.fromOffset(42, 42),
		}),

		Typography = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = theme.headerFont,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(0, 0),
			Text = "flipbook",
			TextColor3 = theme.text,
			TextSize = theme.headerTextSize,
		}, {
			UIPadding = e("UIPadding", {
				PaddingBottom = theme.paddingSmall,
			}),
		}),
	})
end

return hook(Branding)
