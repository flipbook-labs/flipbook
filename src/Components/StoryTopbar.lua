local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement
local defaultProps = {
	height = 50,
}

export type Props = typeof(defaultProps) & {
	layoutOrder: number?,
}

local function StoryTopbar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, 0, 0, props.height),
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

return hook(StoryTopbar, {
	defaultProps = defaultProps,
})
