local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local StoryControlsNavbar = require(flipbook.Components.StoryControlsNavbar)

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
		StoryControlsNavbar = e(StoryControlsNavbar, {
			layoutOrder = 1,
		}),
	})
end

return hook(StoryControls)
