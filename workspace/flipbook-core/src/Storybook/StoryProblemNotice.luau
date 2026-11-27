local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local AlertSeverity = Foundation.Enums.AlertSeverity
local AlertVariant = Foundation.Enums.AlertVariant

local e = React.createElement

export type Props = {
	problem: string,
}

--[[
	Shown while the latest edit to a Story fails to load. It sits along the
	bottom of its parent, over whatever is there, so the parent's layout
	doesn't change when it appears.
]]
local function StoryProblemNotice(props: Props)
	--[[
		Storyteller's `problem` is the error as ModuleLoader raised it: the
		error's message on the first line, then a traceback through
		ModuleLoader's own functions. The message names the module and line
		that failed, so the notice shows that line alone and leaves the
		traceback out.
	]]
	local message = props.problem:match("^[^\n]*") or props.problem

	return e(Foundation.View, {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		ZIndex = 2,
		tag = "auto-y padding-medium size-full-0",
	}, {
		Alert = e(Foundation.Alert, {
			variant = AlertVariant.Feedback,
			severity = AlertSeverity.Error,
			text = message,
			testId = "story-problem-notice",
		}),
	})
end

return StoryProblemNotice
