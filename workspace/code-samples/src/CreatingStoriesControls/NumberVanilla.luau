local controls = {
	count = 1,
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
