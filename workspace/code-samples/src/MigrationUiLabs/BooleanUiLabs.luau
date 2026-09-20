local UILabs = require("@pkg/UILabs")

local controls = {
	isVisible = UILabs.Boolean(true),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
