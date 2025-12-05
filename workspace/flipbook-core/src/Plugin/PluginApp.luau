local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")
local Storyteller = require("@pkg/Storyteller")

local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local TelemetryOptOutDialog = require("@root/Telemetry/TelemetryOptOutDialog")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = SignalsReact.useSignalState

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local function App()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)
	local flipbookStore = useSignalState(FlipbookStore.get)
	local storyModule = useSignalState(flipbookStore.getStoryModule)

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
				Sidebar = React.createElement(Sidebar),
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
					Screen = React.createElement(Screen),
				}),
			}),
		}),

		TelemetryOptOutDialog = React.createElement(TelemetryOptOutDialog),
	})
end

return React.memo(App)
