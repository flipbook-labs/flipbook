local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local CodeBlock = require("@root/Common/CodeBlock")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

export type Props = {
	LayoutOrder: number?,
	problem: string,
}

local function StoryProblemNotice(props: Props)
	local tokens = useTokens()

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col gap-small padding-large size-full-0",
	}, {
		Heading = e(Foundation.Text, {
			LayoutOrder = 1,
			Text = "Showing the last version that loaded. The latest edit has an error:",
			tag = "auto-y size-full-0 text-align-x-left text-body-medium text-wrap",
		}),

		Problem = e(CodeBlock, {
			layoutOrder = 2,
			source = props.problem,
			sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
		}),
	})
end

return StoryProblemNotice
