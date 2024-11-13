local Button = require(script.Parent.Button)

return {
	story = function()
		return Button({
			text = "Click Me",
			onActivated = function()
				print("click")
			end,
		})
	end,
}
