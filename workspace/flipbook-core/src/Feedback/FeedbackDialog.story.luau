local React = require("@pkg/React")

local FeedbackDialog = require("./FeedbackDialog")

local controls = {
	requestSucceeds = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	controls = controls,
	story = function(props: Props)
		return React.createElement(FeedbackDialog, {
			onClose = function()
				print("onClose")
			end,
			-- Stands in for the request. It waits a moment so Submit shows its
			-- pending state, then succeeds or fails per `requestSucceeds`.
			postFeedbackAsync = function()
				task.wait(1)
				return props.controls.requestSucceeds
			end,
		})
	end,
}
