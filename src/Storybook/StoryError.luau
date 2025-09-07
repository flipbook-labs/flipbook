local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local SelectableTextLabel = require("@root/Forms/SelectableTextLabel")

local useTokens = Foundation.Hooks.useTokens

export type Props = {
	err: string,
	layoutOrder: number?,
}

local function StoryError(props: Props)
	local tokens = useTokens()

	return React.createElement(SelectableTextLabel, {
		LayoutOrder = props.layoutOrder,
		Text = props.err,
		TextColor3 = tokens.Color.System.Alert.Color3,
	})
end

return StoryError
