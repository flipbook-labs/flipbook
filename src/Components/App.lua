local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)

local function App(_props, _hooks: any)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Label = Roact.createElement("TextLabel", {
			Text = "Hello, World!",
		}),
	})
end

return RoactHooks.new(Roact)(App)
