local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local CodeBlock = require("@root/Common/CodeBlock")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

export type Props = {
	problem: string,
	onReload: () -> (),
}

local function AppErrorFallback(props: Props)
	local tokens = useTokens()

	return e(Foundation.View, {
		tag = "size-full col bg-surface-200 gap-medium padding-large align-x-center",
	}, {
		Message = e(Foundation.Text, {
			tag = "auto-xy text-heading-medium",
			Text = "Flipbook ran into a problem",
			LayoutOrder = nextLayoutOrder(),
		}),

		Reload = e(Foundation.Button, {
			text = "Reload Flipbook",
			onActivated = props.onReload,
			LayoutOrder = nextLayoutOrder(),
		}),

		Details = e(Foundation.ScrollView, {
			scroll = {
				ScrollingDirection = Enum.ScrollingDirection.Y,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(1, 0),
			},
			layout = {
				FillDirection = Enum.FillDirection.Vertical,
			},
			tag = "size-full shrink",
			LayoutOrder = nextLayoutOrder(),
		}, {
			CodeBlock = e(CodeBlock, {
				source = props.problem,
				sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
			}),
		}),
	})
end

return AppErrorFallback
