-- Make sure to adjust the path to Roact if needed
local Roact = require(script.Parent.Parent.Roact)

return {
	roact = Roact,
	storyRoots = {
		script.Parent.Components,
	},
}
