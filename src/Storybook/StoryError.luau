local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local CodeBlock = require("@root/Common/CodeBlock")

local useTokens = Foundation.Hooks.useTokens

export type Props = {
	err: string,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local tokens = useTokens()

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full padding-small gap-medium",
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.XY,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.new(0, 0),
		},
		LayoutOrder = props.layoutOrder,
	}, {
		CodeBlock = React.createElement(CodeBlock, {
			source = props.err,
			sourceColor = tokens.Color.ActionAlert.Background.Color3,
		}),
	})
end

return StoryError
