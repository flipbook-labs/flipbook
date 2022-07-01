local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function Divider(props: Props)
	return e("Frame", {
		BackgroundColor3 = useTailwind("gray-300"),
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(0, 1, 1, 0),
	})
end

return hook(Divider)
