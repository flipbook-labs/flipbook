local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Navbar = require(script.Navbar)
local Roact = require(flipbook.Packages.Roact)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
}

local function StoryControls(props: Props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
	}, {
		Navbar = e(Navbar, {
			layoutOrder = 1,
		}),
	})
end

return hook(StoryControls)
