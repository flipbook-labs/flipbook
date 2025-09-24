local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

type Props = {
	layoutOrder: number?,
}

local function Branding(props: Props)
	local tokens = useTokens()

	return e(Foundation.View, {
		tag = "auto-xy row gap-small align-y-center",
		LayoutOrder = props.layoutOrder,
	}, {
		Icon = e(Foundation.Image, {
			LayoutOrder = nextLayoutOrder(),
			Image = constants.FLIPBOOK_LOGO,
			Size = UDim2.fromOffset(tokens.Size.Size_800, tokens.Size.Size_800),
		}),

		Typography = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			LayoutOrder = nextLayoutOrder(),
			Text = "Flipbook",
		}),
	})
end

return Branding
