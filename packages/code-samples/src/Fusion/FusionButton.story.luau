local FusionButton = require(script.Parent.FusionButton)

return {
	story = function()
		return FusionButton({
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
