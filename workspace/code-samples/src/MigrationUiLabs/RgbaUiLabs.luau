local UILabs = require("@pkg/UILabs")

local controls = {
	frameColor = UILabs.RGBA(Color3.new(1, 1, 1), 0),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
