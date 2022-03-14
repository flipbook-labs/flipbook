local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local Sidebar = require(script.Parent.Sidebar)
local Canvas = require(script.Parent.Canvas)
local useStorybooks = require(script.Parent.Parent.Hooks.useStorybooks)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local loader = ModuleLoader.new()

local function App(_props, hooks: any)
	local theme = useTheme(hooks)
	local storybooks = useStorybooks(hooks, game, loader)
	local story, selectStory = hooks.useState(nil)
	local storybook, selectStorybook = hooks.useState(nil)

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.background,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 20),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Sidebar = Roact.createElement(Sidebar, {
			storybooks = storybooks,
			selectStory = selectStory,
			selectStorybook = selectStorybook,
		}),

		Canvas = Roact.createElement(Canvas, {
			story = story,
			storybook = storybook,
			loader = loader,
		}),
	})
end

return RoactHooks.new(Roact)(App)
