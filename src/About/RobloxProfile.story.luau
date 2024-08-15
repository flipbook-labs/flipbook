local React = require("@pkg/React")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
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
		return React.createElement(ContextProviders, {
			plugin = MockPlugin.new(),
		}, {
			RobloxProfiler = React.createElement(RobloxProfile, {
				userId = tonumber(props.controls.userId),
			}),
		})
	end,
}
