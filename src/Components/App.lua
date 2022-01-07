local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStorybooks = require(script.Parent.Parent.Hooks.useStorybooks)
local Sidebar = require(script.Parent.Sidebar)
local StoryView = require(script.Parent.StoryView)

local function App(_props, hooks: any)
	local storybooks = useStorybooks(hooks, game)
	local selectedStory, selectStory = hooks.useState(nil)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		SidebarWrapper = Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1 / 5, 1),
			BackgroundTransparency = 1,
		}, {
			Sidebar = Roact.createElement(Sidebar, {
				storybooks = storybooks,
				selectStory = selectStory,
			}),
		}),

		StoryViewWrapper = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(4 / 5, 1),
			BackgroundTransparency = 1,
		}, {
			StoryView = Roact.createElement(StoryView, {
				story = selectedStory,
			}),
		}),
	})
end

return RoactHooks.new(Roact)(App)
