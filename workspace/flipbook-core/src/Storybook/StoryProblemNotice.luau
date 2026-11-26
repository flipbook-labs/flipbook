local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local CodeBlock = require("@root/Common/CodeBlock")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

-- An error's traceback can run long, and the notice sits above the Story it's
-- keeping on screen. Past this height, the error scrolls instead of pushing
-- the Story down.
local MAX_PROBLEM_HEIGHT = 160

export type Props = {
	LayoutOrder: number?,
	problem: string,
}

local function StoryProblemNotice(props: Props)
	local tokens = useTokens()
	-- The height of the error's text, read from the scrolling frame's canvas.
	local problemHeight, setProblemHeight = React.useBinding(0)

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col gap-small padding-large size-full-0",
	}, {
		Heading = e(Foundation.Text, {
			LayoutOrder = 1,
			Text = "Showing the last version that loaded. The latest edit has an error:",
			tag = "auto-y size-full-0 text-align-x-left text-body-medium text-wrap",
		}),

		Problem = e(Foundation.ScrollView, {
			LayoutOrder = 2,
			Size = problemHeight:map(function(height: number)
				return UDim2.new(1, 0, 0, math.min(height, MAX_PROBLEM_HEIGHT))
			end),
			scroll = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(1, 0),
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			onAbsoluteCanvasSizeChanged = function(frame: ScrollingFrame)
				setProblemHeight(frame.AbsoluteCanvasSize.Y)
			end,
		}, {
			CodeBlock = e(CodeBlock, {
				source = props.problem,
				sourceColor = tokens.Color.ActionAlert.Foreground.Color3,
			}),
		}),
	})
end

return StoryProblemNotice
