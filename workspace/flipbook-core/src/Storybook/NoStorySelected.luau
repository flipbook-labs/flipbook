local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

local function NoStorySelected()
	local tokens = useTokens()

	return e(Foundation.View, {
		tag = "size-full col bg-surface-200 gap-medium align-y-center align-x-center",
	}, {
		Icon = e(Foundation.Icon, {
			name = Foundation.Enums.IconName.SquareBooks,
			style = tokens.Color.ActionStandard.Foreground,
			size = Foundation.Enums.IconSize.Large,
			LayoutOrder = nextLayoutOrder(),
		}),

		Message = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			Text = "Select a story to preview it",
			LayoutOrder = nextLayoutOrder(),
		}),
	})
end

return NoStorySelected
