local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local t = require(script.Parent.Pa.Packages.t)

local validateProps = t.interface({
	storyRoot = t.instance,
})

local function App(props, hooks: any)
	assert(validateProps(props))

	local selectedStory, setSelectedStory = hooks.useState(nil)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {})
end

return RoactHooks.new(Roact)(App)
