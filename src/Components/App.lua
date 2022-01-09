local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStorybooks = require(script.Parent.Parent.Hooks.useStorybooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local assets = require(script.Parent.Parent.assets)
local Sidebar = require(script.Parent.Sidebar)
local StoryView = require(script.Parent.StoryView)
local NoStorySelected = require(script.Parent.NoStorySelected)

local SIDEBAR_WIDTH_EXPANDED = 250 -- px
local SIDEBAR_WIDTH_COLLAPSED = 24 -- px

local function App(_props, hooks: any)
	local theme = useTheme(hooks)
	local storybooks = useStorybooks(hooks, game)
	local story, selectStory = hooks.useState(nil)
	local sidebarWidth, setSidebarWidth = hooks.useState(SIDEBAR_WIDTH_EXPANDED)
	local isExpanded, setIsExpanded = hooks.useState(true)

	local toggleSidebar = hooks.useCallback(function()
		setIsExpanded(function(prev)
			return not prev
		end)
	end, { setIsExpanded })

	hooks.useEffect(function()
		setSidebarWidth(if isExpanded then SIDEBAR_WIDTH_EXPANDED else SIDEBAR_WIDTH_COLLAPSED)
	end, { isExpanded })

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		SidebarWrapper = Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(0, sidebarWidth, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Toggle = Roact.createElement("ImageButton", {
				Image = assets["double-arrow"],
				Rotation = if isExpanded then 180 else 0,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(20, 28),
				Position = UDim2.fromScale(1, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 2,
				BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
				[Roact.Event.Activated] = toggleSidebar,
			}, {
				Border = Roact.createElement("UIStroke", {
					Color = theme:GetColor(Enum.StudioStyleGuideColor.Border),
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Thickness = 2,
				}),
			}),

			Sidebar = Roact.createElement(Sidebar, {
				storybooks = storybooks,
				selectStory = selectStory,
			}),
		}),

		StoryViewWrapper = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, -sidebarWidth, 1, 0),
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
