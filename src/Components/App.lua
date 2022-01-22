local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStorybooks = require(script.Parent.Parent.Hooks.useStorybooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local Sidebar = require(script.Parent.Sidebar)
local StoryView = require(script.Parent.StoryView)
local NoStorySelected = require(script.Parent.NoStorySelected)

local SIDEBAR_WIDTH = NumberRange.new(24, 250)

local function App(_props, hooks: any)
	local theme = useTheme(hooks)
	local storybooks = useStorybooks(hooks, game)
	local story, selectStory = hooks.useState(nil)
	local isSidebarExpanded, setIsSidebarExpanded = hooks.useState(true)

	local toggleSidebar = hooks.useCallback(function()
		setIsSidebarExpanded(function(prev)
			return not prev
		end)
	end, { setIsSidebarExpanded })

	local previewOffset = if isSidebarExpanded then -SIDEBAR_WIDTH.Max else 0

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		Sidebar = Roact.createElement(Sidebar, {
			layoutOrder = 1,
			storybooks = storybooks,
			selectStory = selectStory,
			isExpanded = isSidebarExpanded,
			width = SIDEBAR_WIDTH,
			onToggleActivated = toggleSidebar,
		}),

		StoryViewWrapper = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, previewOffset, 1, 0),
			BackgroundTransparency = 1,
		}, {
			StoryView = story and Roact.createElement(StoryView, {
				story = story,
			}),

			NoStorySelected = not story and Roact.createElement(NoStorySelected),
		}),
	})
end

return RoactHooks.new(Roact)(App)