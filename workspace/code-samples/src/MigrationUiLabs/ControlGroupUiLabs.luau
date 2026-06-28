local UILabs = require("@pkg/UILabs")

local controls = {
	Audio = UILabs.ControlGroup({
		volume = UILabs.Slider(50, 0, 100, 1),
		muted = UILabs.Boolean(false),
	}),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
