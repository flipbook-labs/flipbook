local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local Roact = require(flipbook.Packages.Roact)
local RoactHooks = require(flipbook.Packages.RoactHooks)
local styles = require(flipbook.styles)
local useStorybooks = require(flipbook.Hooks.useStorybooks)
local useTheme = require(flipbook.Hooks.useTheme)
local Canvas = require(script.Parent.Canvas)
local Sidebar = require(script.Parent.Sidebar)

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
