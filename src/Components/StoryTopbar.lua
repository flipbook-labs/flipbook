local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function StoryTopbar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, 0, 0, 50),
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = theme.stroke,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
		}),
	})
end

return hook(StoryTopbar)
