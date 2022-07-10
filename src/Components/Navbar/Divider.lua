local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function Divider(props: Props, hooks: any)
	local theme = useTheme(hooks)
	return e("Frame", {
		BackgroundColor3 = theme.diver,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 1, 1, 0),
	})
end

return hook(Divider)
