local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement

export type Props = {
	LayoutOrder: number?,
	problem: string,
}

local function StoryProblemNotice(props: Props)
	local tokens = useTokens()
	--[[
		Storyteller's `problem` is the error as ModuleLoader raised it: the
		error's message on the first line, then a traceback through
		ModuleLoader's own functions. The message names the module and line
		that failed, so the notice shows that line alone and leaves the
		traceback out.
	]]
	local message = props.problem:match("^[^\n]*") or props.problem

	return e(Foundation.View, {
		LayoutOrder = props.LayoutOrder,
		tag = "auto-y col gap-small padding-large size-full-0",
	}, {
		Heading = e(Foundation.Text, {
			LayoutOrder = 1,
			Text = "The latest edit has an error",
			tag = "auto-y content-emphasis size-full-0 text-align-x-left text-body-medium text-wrap",
		}),

		Problem = e("TextLabel", {
			LayoutOrder = 2,
			Text = message,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.RobotoMono,
			TextSize = tokens.Typography.BodyMedium.FontSize,
			TextColor3 = tokens.Color.ActionAlert.Foreground.Color3,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),
	})
end

return StoryProblemNotice
