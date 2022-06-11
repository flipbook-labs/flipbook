local Canvas = require(script.Parent.Canvas)
local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local Sidebar = require(script.Parent.Sidebar)
local styles = require(script.Parent.Parent.styles)
local useStorybooks = require(script.Parent.Parent.Hooks.useStorybooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

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
			Padding = styles.LARGE_PADDING,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Sidebar = Roact.createElement(Sidebar, {
			layoutOrder = 1,
			selectStory = selectStory,
			selectStorybook = selectStorybook,
			storybooks = storybooks,
		}),

		Canvas = Roact.createElement(Canvas, {
			loader = loader,
			story = story,
			storybook = storybook,
		}),
	})
end

return RoactHooks.new(Roact)(App)
