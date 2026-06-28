local UILabs = require("@pkg/UILabs")

local controls = {
	greeting = UILabs.String("Hello, World!"),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
