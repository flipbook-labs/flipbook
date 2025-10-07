local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)

local CodeBlock = require(script.Parent.Parent.Common.CodeBlock)

local useTokens = Foundation.Hooks.useTokens

export type Props = {
	LayoutOrder: number?,
	errorMessage: string,
}

local function StoryError(props: Props)
	local tokens = useTokens()

	return React.createElement(Foundation.ScrollView, {
		LayoutOrder = props.LayoutOrder,
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(1, 0),
		},
		tag = "size-full padding-small gap-medium",
	}, {
		CodeBlock = React.createElement(CodeBlock, {
			source = props.errorMessage,
			sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
		}),
	})
end

return StoryError
