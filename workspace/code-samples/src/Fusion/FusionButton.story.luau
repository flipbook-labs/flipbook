local FusionButton = require("./FusionButton")

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
