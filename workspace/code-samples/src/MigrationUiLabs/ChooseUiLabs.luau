local UILabs = require("@pkg/UILabs")

local controls = {
	theme = UILabs.Choose({ "Dark", "Light" }),
	size = UILabs.Choose({ "Small", "Medium", "Large" }, 2),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
