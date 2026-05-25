local React = require("@pkg/React")

local LocaleSwitcher = require("./LocaleSwitcher")

return {
	story = function(props)
		print(props.locale)
		return React.createElement(LocaleSwitcher)
	end,
}
