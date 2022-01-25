local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local Sidebar = require(script.Parent.Sidebar)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local SIDEBAR_WIDTH = NumberRange.new(220, 220)

local function App(_, hooks)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.background,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Sidebar = Roact.createElement(Sidebar, {
			isExpanded = false,
			layoutOrder = 1,
			width = SIDEBAR_WIDTH,
		}),
	})
end

return hook(App)
