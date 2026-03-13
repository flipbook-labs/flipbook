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
		local userId = assert(tonumber(props.controls.userId))

		return React.createElement(RobloxProfile, {
			userId = userId,
		})
	end,
}
