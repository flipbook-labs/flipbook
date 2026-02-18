local React = require("@pkg/React")

local LogsView = require("./LogsView")

return {
	story = function()
		return React.createElement(LogsView)
	end,
}
