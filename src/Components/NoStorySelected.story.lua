local Roact = require(script.Parent.Parent.Packages.Roact)
local NoStorySelected = require(script.Parent.NoStorySelected)

return {
	roact = Roact,
	story = Roact.createElement(NoStorySelected),
}
