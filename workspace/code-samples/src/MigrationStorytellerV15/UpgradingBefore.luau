local story = {
	controls = {
		label = "Hello",
		count = 5,
		isVisible = true,
		size = { "Small", "Medium", "Large" },
		alignment = { "Left", "Center", "Right" },
	},
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
