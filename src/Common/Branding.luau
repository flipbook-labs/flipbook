local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local e = React.createElement

type Props = {
	layoutOrder: number?,
}

local function Branding(props: Props)
	return e(Foundation.View, {
		tag = "auto-xy row gap-small align-y-center",
		LayoutOrder = props.layoutOrder,
	}, {
		Icon = e(Sprite, {
			layoutOrder = nextLayoutOrder(),
			image = assets.IconLight,
			size = UDim2.fromOffset(42, 42),
		}),

		Typography = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			LayoutOrder = nextLayoutOrder(),
			Text = "Flipbook",
		}),
	})
end

return Branding
