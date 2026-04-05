local React = require("@pkg/React")

local ThemeSwitcher = require("./ThemeSwitcher")

return {
	story = function(props)
		print(props.theme)
		return React.createElement(ThemeSwitcher)
	end,
}
