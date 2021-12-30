local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local getStories = require(script.Parent.Parent.getStories)
local Sidebar = require(script.Parent.Sidebar)

local function App(_props, _hooks: any)
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Sidebar = Roact.createElement(Sidebar, {
			stories = getStories(ReplicatedStorage),
			maxSize = Vector2.new(200, math.huge),
		}),
	})
end

return RoactHooks.new(Roact)(App)
