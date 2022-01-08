local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local styles = require(script.Parent.Parent.styles)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

export type Props = {
	layoutOrder: number,
}

local function Panel(props: any, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		Size = UDim2.fromScale(1, 0),
		BorderMode = Enum.BorderMode.Inset,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = styles.PADDING,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.LARGE_PADDING,
			PaddingRight = styles.LARGE_PADDING,
			PaddingBottom = styles.LARGE_PADDING,
			PaddingLeft = styles.LARGE_PADDING,
		}),

		Border = Roact.createElement("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 2,
		}),

		Children = Roact.createFragment(props[Roact.Children]),
	})
end

return RoactHooks.new(Roact)(Panel)
