local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local ReactPanelLayout = require("@workspace/react-panel-layout/src")

local NavigationContext = require("@root/Navigation/NavigationContext")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local TelemetryOptOutDialog = require("@root/Telemetry/TelemetryOptOutDialog")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local useSignalState = ReactCharm.useSignalState

local defaultStorybook = createLoadedStorybook()

local function App()
	local storyModule: ModuleScript?, setStoryModule = React.useState(nil :: ModuleScript?)
	local storybook, setStorybook = React.useState(nil :: LoadedStorybook?)
	local unavailableStorybook: UnavailableStorybook?, setUnavailableStorybook =
		React.useState(nil :: UnavailableStorybook?)
	local navigation = NavigationContext.use()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local onStoryChanged = React.useCallback(function(newStoryModule: ModuleScript?, newStorybook: LoadedStorybook?)
		navigation.navigateTo("Home")

		setUnavailableStorybook(nil)

		if newStoryModule and not newStorybook then
			newStorybook = defaultStorybook
		end

		task.spawn(function()
			fireEventAsync({
				eventName = "StoryOpened",
			})
		end)

		setStoryModule(newStoryModule)
		setStorybook(newStorybook)
	end, { navigation.navigateTo } :: { unknown })

	local onShowErrorPage = React.useCallback(function(newUnavailableStorybook: UnavailableStorybook)
		setStoryModule(nil)
		setStorybook(nil)
		setUnavailableStorybook(newUnavailableStorybook)
	end, {})

	return React.createElement(StoryActionsContext.Provider, {
		story = storyModule,
	}, {
		Root = React.createElement(ReactPanelLayout.Group, {
			id = "root",
			orientation = "horizontal",
		}, {
			Sidebar = React.createElement(ReactPanelLayout.Panel, {
				id = "sidebar",
				LayoutOrder = 1,
				defaultSize = userSettings.sidebarWidth,
				sizeConstraints = NumberRange.new(constants.SIDEBAR_MIN_WIDTH, constants.SIDEBAR_MAX_WIDTH),
			}, {
				Sidebar = React.createElement(Sidebar, {
					onStoryChanged = onStoryChanged,
					onShowErrorPage = onShowErrorPage,
				}),
			}),

			Main = React.createElement(ReactPanelLayout.Panel, {
				id = "main",
				LayoutOrder = 2,
				defaultSize = 80,
			}, {
				MainContent = React.createElement(Foundation.View, {
					tag = "size-full col",
				}, {
					Topbar = React.createElement(Topbar, {
						LayoutOrder = 1,
					}),

					ScreenWrapper = React.createElement(Foundation.View, {
						LayoutOrder = 2,
						tag = "size-full shrink",
					}, {
						Screen = React.createElement(Screen, {
							story = storyModule,
							storybook = storybook,
							unavailableStorybook = unavailableStorybook,
						}),
					}),
				}),
			}),
		}),

		TelemetryOptOutDialog = React.createElement(TelemetryOptOutDialog),
	})
end

return App
