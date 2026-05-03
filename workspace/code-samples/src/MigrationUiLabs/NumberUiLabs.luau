local UILabs = require("@pkg/UILabs")

local controls = {
	count = UILabs.Number(0, 0, 100, 1),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
