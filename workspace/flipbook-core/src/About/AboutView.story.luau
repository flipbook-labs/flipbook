local React = require("@pkg/React")

local AboutView = require("./AboutView")

return {
	story = function()
		return React.createElement(AboutView)
	end,
}
