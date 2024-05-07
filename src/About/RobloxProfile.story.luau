local React = require("@pkg/React")

local RobloxProfile = require("./RobloxProfile")

local controls = {
	userId = 1,
}

type Props = {
	controls: typeof(controls),
}
return {
	controls = controls,
	story = function(props: Props)
		return React.createElement(RobloxProfile, {
			userId = tonumber(props.controls.userId),
		})
	end,
}
