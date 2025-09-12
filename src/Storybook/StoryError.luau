local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local CodeBlock = require("@root/Common/CodeBlock")

local useTokens = Foundation.Hooks.useTokens

type LoadedStory<T> = Storyteller.LoadedStory<T>

export type Props = {
	err: string,
	storyModule: ModuleScript,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local tokens = useTokens()

	return React.createElement(Foundation.ScrollView, {
		tag = "size-full padding-small gap-medium",
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(1, 0),
		},
		LayoutOrder = props.layoutOrder,
	}, {
		CodeBlock = React.createElement(CodeBlock, {
			source = props.err,
			sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
		}),
	})
end

return StoryError
