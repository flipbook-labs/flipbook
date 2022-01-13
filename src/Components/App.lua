local hook = require(script.Parent.Parent.hook)]
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local function App(_, hooks)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.background,
		Size = UDim2.fromScale(1, 1)
	})
end

return hook(App)
