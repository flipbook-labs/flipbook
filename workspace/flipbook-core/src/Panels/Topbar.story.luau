local React = require("@pkg/React")

local Topbar = require("./Topbar")

local e = React.createElement

local controls = {
	showDevBadge = false,
	showBetaBadge = false,
	showInternalBadge = false,
}

type Props = {
	controls: typeof(controls),
}

return {
	summary = "Top bar with story actions, color mode and theme pickers, and environment badges",
	controls = controls,
	story = function(props: Props)
		return e(Topbar, {
			showDevBadge = props.controls.showDevBadge,
			showBetaBadge = props.controls.showBetaBadge,
			showInternalBadge = props.controls.showInternalBadge,
		})
	end,
}
