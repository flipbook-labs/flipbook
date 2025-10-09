local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")
local Storyteller = require("@pkg/Storyteller")
local Telemetry = require("@workspace/telemetry/src")

local NavigationContext = require("@root/Navigation/NavigationContext")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = SignalsReact.useSignalState

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local defaultStorybook = createLoadedStorybook()

local function App()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local storybooks = Storyteller.useStorybooks(game)
	local storyModule: ModuleScript?, setStoryModule = React.useState(nil :: ModuleScript?)
	local storybook, setStorybook = React.useState(nil :: LoadedStorybook?)
	local unavailableStorybook: UnavailableStorybook?, setUnavailableStorybook =
		React.useState(nil :: UnavailableStorybook?)
	local navigation = NavigationContext.use()

	local onStoryChanged = React.useCallback(function(newStoryModule: ModuleScript?, newStorybook: LoadedStorybook?)
		navigation.navigateTo("Home")

		setUnavailableStorybook(nil)

		if newStoryModule and not newStorybook then
			newStorybook = defaultStorybook
		end

		Telemetry.fireEvent({
			eventName = "StoryOpened",
		})

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
		StoryActionsProvider = React.createElement(StoryActionsContext.Provider, {
			story = storyModule,
		}, {
			SidebarWrapper = React.createElement(ResizablePanel, {
				LayoutOrder = nextLayoutOrder(),
				initialSize = UDim2.new(0, userSettings.sidebarWidth, 1, 0),
				dragHandles = { "Right" :: "Right" },
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
					LayoutOrder = nextLayoutOrder(),
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
	})
end

return App
