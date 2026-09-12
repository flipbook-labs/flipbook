local controls = {
	greeting = "Hello, World!",
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
