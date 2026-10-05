local React = require("@pkg/React")

local Sidebar = require("./Sidebar")

return {
	summary = "Sidebar containing brand, searchbar, and component tree",
	controls = {},
	story = function()
		return React.createElement(Sidebar)
	end,
}
