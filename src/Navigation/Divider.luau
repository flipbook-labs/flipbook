local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local useTheme = require(flipbook.Common.useTheme)

local e = React.createElement

type Props = {
	layoutOrder: number,
}

local function Divider(props: Props)
	local theme = useTheme()
	return e("Frame", {
		BackgroundColor3 = theme.divider,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 1, 1, 0),
	})
end

return Divider
