local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local hook = require(flipbook.hook)
local types = require(flipbook.types)
local useStorybooks = require(flipbook.Hooks.useStorybooks)
local useTailwind = require(flipbook.Hooks.useTailwind)
local Sidebar = require(script.Parent.Sidebar)
local Canvas = require(script.Parent.Canvas)

local loader = ModuleLoader.new()

local function App(_props, hooks: any)
	local storybooks = useStorybooks(hooks, game, loader)
	local story, setStory = hooks.useState(nil)
	local storybook, selectStorybook = hooks.useState(nil)

	local selectStory = hooks.useCallback(function(newStory: ModuleScript)
		setStory(function(prevStory: types.Story)
			return if prevStory ~= newStory then newStory else nil
		end)
	end, { setStory })

	return Roact.createElement("Frame", {
		BackgroundColor3 = useTailwind("gray-100"),
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 0),
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
			layoutOrder = 2,
			loader = loader,
			story = story,
			storybook = storybook,
		}),
	})
end

return hook(App)
