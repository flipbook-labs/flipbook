local Foundation = require("@rbxpkg/Foundation")
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

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local function App()
	local settingsContext = SettingsContext.use()
	local storybooks = Storyteller.useStorybooks(game)
	local storyModule: ModuleScript?, setStoryModule = React.useState(nil :: ModuleScript?)
	local storybook, setStorybook = React.useState(nil :: LoadedStorybook?)
	local unavailableStorybook: UnavailableStorybook?, setUnavailableStorybook =
		React.useState(nil :: UnavailableStorybook?)
	local initialSidebarWidth = settingsContext.getSetting("sidebarWidth")
	local navigation = NavigationContext.use()

	local onStoryChanged = React.useCallback(function(newStoryModule: ModuleScript?, newStorybook: LoadedStorybook?)
		navigation.navigateTo("Home")

		setUnavailableStorybook(nil)
		setStoryModule(newStoryModule)
		setStorybook(newStorybook)
	end, { navigation.navigateTo } :: { unknown })

	local onShowErrorPage = React.useCallback(function(newUnavailableStorybook: UnavailableStorybook)
		setStoryModule(nil)
		setStorybook(nil)
		setUnavailableStorybook(newUnavailableStorybook)
	end, {})

	return React.createElement(Foundation.View, {
		tag = "size-full row align-y-center flex-between",
	}, {
		SidebarWrapper = React.createElement(ResizablePanel, {
			layoutOrder = nextLayoutOrder(),
			initialSize = UDim2.new(0, initialSidebarWidth, 1, 0),
			dragHandles = {
				-- Luau FIXME: Type '{string}' could not be converted into '{"Bottom" | "Left" | "Right" | "Top"}'
				"Right" :: any,
			},
			minSize = Vector2.new(constants.SIDEBAR_MIN_WIDTH, 0),
			maxSize = Vector2.new(constants.SIDEBAR_MAX_WIDTH, math.huge),
		}, {
			Sidebar = React.createElement(Sidebar, {
				onStoryChanged = onStoryChanged,
				onShowErrorPage = onShowErrorPage,
				storybooks = storybooks,
			}),
		}),

		MainWrapper = React.createElement(Foundation.View, {
			tag = "size-full col shrink",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Topbar = React.createElement(Topbar, {
				LayoutOrder = nextLayoutOrder(),
			}),

			ScreenWrapper = React.createElement(Foundation.View, {
				tag = "size-full shrink",
				LayoutOrder = nextLayoutOrder(),
			}, {
				Screen = React.createElement(Screen, {
					story = storyModule,
					storybook = storybook,
					unavailableStorybook = unavailableStorybook,
				}),
			}),
		}),
	})
end

return App
