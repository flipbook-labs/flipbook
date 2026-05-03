local Storyteller = require("@pkg/Storyteller")

local labels: { [number]: string } = {
	[500] = "Mobile",
	[1000] = "Tablet",
	[1500] = "Desktop",
}

local controls = {
	windowSize = Storyteller.createSelectControl({ 500, 1000, 1500 }, {
		default = 500,
		tostring = function(value)
			if type(value) == "number" then
				return labels[value] or tostring(value)
			end

			return tostring(value)
		end,
	}),
}

local story = {
	controls = controls,
	story = function(_props)
		return Instance.new("TextLabel")
	end,
}

return story
