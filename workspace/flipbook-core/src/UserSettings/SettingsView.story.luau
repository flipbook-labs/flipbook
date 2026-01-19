local React = require("@pkg/React")

local SettingsView = require("./SettingsView")

return {
	story = function()
		return React.createElement(SettingsView)
	end,
}
