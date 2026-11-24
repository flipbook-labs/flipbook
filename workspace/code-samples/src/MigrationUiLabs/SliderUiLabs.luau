local UILabs = require("@pkg/UILabs")

local controls = {
	volume = UILabs.Slider(50, 0, 100, 1),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
