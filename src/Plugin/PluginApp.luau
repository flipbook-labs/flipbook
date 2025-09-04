local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local NavigationContext = require("@root/Navigation/NavigationContext")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local Sidebar = require("@root/Panels/Sidebar")
local Topbar = require("@root/Panels/Topbar")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local TOPBAR_HEIGHT_PX = 32

type LoadedStorybook = Storyteller.LoadedStorybook

local function App()
	local theme = useTheme()
	local settingsContext = SettingsContext.use()
	local storybooks = Storyteller.useStorybooks(game)
	local storyModule: ModuleScript?, setStoryModule = React.useState(nil :: ModuleScript?)
	local storybook, setStorybook = React.useState(nil :: LoadedStorybook?)
	local initialSidebarWidth = settingsContext.getSetting("sidebarWidth")
	local sidebarWidth, setSidebarWidth = React.useState(initialSidebarWidth)
	local navigation = NavigationContext.use()

	local onStoryChanged = React.useCallback(function(newStoryModule: ModuleScript?, newStorybook: LoadedStorybook?)
		navigation.navigateTo("Home")

		setStoryModule(function(prev: ModuleScript?)
			return if prev ~= newStoryModule then newStoryModule else nil
		end)

		setStorybook(newStorybook)
	end, { navigation.navigateTo } :: { unknown })

	local onSidebarResized = React.useCallback(function(newSize: Vector2)
		setSidebarWidth(newSize.X)
	end, {})

	return React.createElement("Frame", {
		BackgroundColor3 = theme.background,
		Size = UDim2.fromScale(1, 1),
	}, {
		Layout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		SidebarWrapper = React.createElement(ResizablePanel, {
			layoutOrder = nextLayoutOrder(),
			initialSize = UDim2.new(0, initialSidebarWidth, 1, 0),
			dragHandles = {
				-- Luau FIXME: Type '{string}' could not be converted into '{"Bottom" | "Left" | "Right" | "Top"}'
				"Right" :: any,
			},
			minSize = Vector2.new(constants.SIDEBAR_MIN_WIDTH, 0),
			maxSize = Vector2.new(constants.SIDEBAR_MAX_WIDTH, math.huge),
			onResize = onSidebarResized,
		}, {
			Sidebar = React.createElement(Sidebar, {
				onStoryChanged = onStoryChanged,
				storybooks = storybooks.available,
			}),
		}),

		MainWrapper = React.createElement("Frame", {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(sidebarWidth, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Topbar = React.createElement(Topbar, {
				Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT_PX),
				LayoutOrder = nextLayoutOrder(),
			}),

			ScreenWrapper = React.createElement("Frame", {
				LayoutOrder = nextLayoutOrder(),
				Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, TOPBAR_HEIGHT_PX),
				BackgroundTransparency = 1,
			}, {
				Screen = React.createElement(Screen, {
					story = storyModule,
					storybook = storybook,
				}),
			}),
		}),
	})
end

return App
