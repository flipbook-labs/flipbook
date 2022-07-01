local flipbook = script:FindFirstAncestor("flipbook")

local assets = require(flipbook.assets)
local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local useDark = require(flipbook.Hooks.useDark)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	layoutOrder: number?,
}

local function Brand(props: Props, hooks: any)
	local dark = useDark(hooks)

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(0, 0),
	}, {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, -5),
		}),

		Icon = e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = assets.IconLight,
			LayoutOrder = 0,
			Size = UDim2.fromOffset(42, 42),
		}),

		Typography = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(0, 0),
			Text = "flipbook",
			TextColor3 = useTailwind("gray-800", "gray-800", dark),
			TextSize = 20,
		}, {
			UIPadding = e("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
			}),
		}),
	})
end

return hook(Brand)
