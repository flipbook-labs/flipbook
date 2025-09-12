local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

local function NoStorySelected()
	local tokens = useTokens()

	return e(Foundation.View, {
		tag = "size-full col bg-surface-200 gap-medium align-y-center align-x-center",
	}, {
		Icon = e(Sprite, {
			image = assets.Storybook,
			layoutOrder = nextLayoutOrder(),
			color = tokens.Color.ActionStandard.Foreground.Color3,
			size = UDim2.fromOffset(tokens.Size.Size_800, tokens.Size.Size_800),
		}),

		Message = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			Text = "Select a story to preview it",
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return NoStorySelected
