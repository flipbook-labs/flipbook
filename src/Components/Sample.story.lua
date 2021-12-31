local Roact = require(script.Parent.Parent.Packages.Roact)

local story = Roact.createElement("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(255, 0, 0),
})

return {
	story = story,
}
