local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local AppMode = require("@root/Enums/AppMode")
local AppStore = require("@root/AppStore")
local BuildChannel = require("@root/Enums/BuildChannel")
local BuildTarget = require("@root/Enums/BuildTarget")
local NavigationContext = require("@root/Navigation/NavigationContext")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local TelemetryOptOutDialog = require("@root/Telemetry/TelemetryOptOutDialog")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = ReactCharm.useSignalState

type AppMode = AppMode.AppMode
type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

export type Props = {
	mode: AppMode?,
}

local function FlipbookApp(props: Props)
	local appStore = useSignalState(AppStore.get)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local storyModule = useSignalState(appStore.getStoryModule)
	local storybook = useSignalState(appStore.getStorybook)
	local unavailableStorybook = useSignalState(appStore.getUnavailableStorybook)
	local hasRefreshedStorybooks = useSignalState(appStore.getHasRefreshedStorybooks)
	local navigation = NavigationContext.use()

	React.useEffect(function()
		if not hasRefreshedStorybooks then
			task.spawn(appStore.refreshStorybooks)
		end
	end, { appStore, hasRefreshedStorybooks } :: { unknown })

	local onStoryChanged = React.useCallback(function(newStoryModule: ModuleScript?, newStorybook: LoadedStorybook?)
		navigation.navigateTo("Home")

		task.spawn(function()
			fireEventAsync({
				eventName = "StoryOpened",
			})
		end)

		appStore.openStory(newStoryModule, newStorybook)
	end, { appStore, navigation.navigateTo } :: { unknown })

	local onShowErrorPage = React.useCallback(function(newUnavailableStorybook: UnavailableStorybook)
		appStore.showUnavailableStorybook(newUnavailableStorybook)
	end, { appStore })

	return React.createElement(Foundation.View, {
		tag = "size-full row align-y-center flex-between",
	}, {
		StoryActionsProvider = React.createElement(StoryActionsContext.Provider, {
			story = storyModule,
			mode = props.mode,
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
				}),
			}),

			MainWrapper = React.createElement(Foundation.View, {
				tag = "size-full col shrink bg-surface-100",
				LayoutOrder = nextLayoutOrder(),
			}, {
				Topbar = React.createElement(Topbar, {
					showDevBadge = _G.BUILD_CHANNEL == BuildChannel.Development,
					showBetaBadge = _G.BUILD_CHANNEL == BuildChannel.Beta,
					showInternalBadge = _G.BUILD_TARGET == BuildTarget.Rotriever,
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

		TelemetryOptOutDialog = React.createElement(TelemetryOptOutDialog),
	})
end

return FlipbookApp
