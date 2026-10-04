local UILabs = require("@pkg/UILabs")

local controls = {
	windowSize = UILabs.EnumList({
		Mobile = 500,
		Tablet = 1000,
		Desktop = 1500,
	}, "Mobile"),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
