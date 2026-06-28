local controls = {
	size = { "Small", "Medium", "Large" },
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
