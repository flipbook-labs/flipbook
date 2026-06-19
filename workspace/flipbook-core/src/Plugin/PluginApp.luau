local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Storyteller = require("@pkg/Storyteller")

local ActionsContext = require("@root/Actions/ActionsContext")
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
local createLoadedStorybook = require("@root/Storybook/createLoadedStorybook")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useEffect = React.useEffect
local useRef = React.useRef
local useSignalState = ReactCharm.useSignalState

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local defaultStorybook = createLoadedStorybook()

local function App()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

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

	-- Register the app's half of the action controller so actions (triggered by
	-- a shortcut or an agent) can drive navigation and story selection. We
	-- register once and read live state through refs to avoid re-registering on
	-- every render.
	local controller = ActionsContext.use()
	local storybooks = Storyteller.useStorybooks()

	local latest = useRef({
		navigation = navigation,
		storybooks = storybooks,
		storyModule = storyModule,
		onStoryChanged = onStoryChanged,
	})
	latest.current.navigation = navigation
	latest.current.storybooks = storybooks
	latest.current.storyModule = storyModule
	latest.current.onStoryChanged = onStoryChanged

	useEffect(function()
		if not controller then
			return
		end

		return controller.register({
			navigateTo = function(screen: string)
				latest.current.navigation.navigateTo(screen :: any)
			end,

			selectStory = function(path: string)
				local instance = getInstanceFromPath(path)
				if not instance or not instance:IsA("ModuleScript") then
					return { ok = false, error = `no story module at path: {path}` }
				end

				local owningStorybook: LoadedStorybook? = nil
				for _, storybook in latest.current.storybooks.available do
					for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook :: any) do
						if storyModule == instance then
							owningStorybook = storybook :: any
							break
						end
					end
					if owningStorybook then
						break
					end
				end

				latest.current.onStoryChanged(instance, owningStorybook)
				return { ok = true, result = { path = getInstancePath(instance) } }
			end,

			listStories = function()
				local stories = {}
				for _, storybook in latest.current.storybooks.available do
					for _, storyModule in Storyteller.findStoryModulesForStorybook(storybook :: any) do
						table.insert(stories, {
							path = getInstancePath(storyModule),
							name = (storyModule.Name:gsub("%.story", "")),
						})
					end
				end
				return stories
			end,

			getState = function()
				local current = latest.current.storyModule
				return {
					screen = latest.current.navigation.currentScreen,
					selectedStory = if current then getInstancePath(current) else nil,
				}
			end,
		})
	end, { controller } :: { unknown })

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
				}),
			}),

			MainWrapper = React.createElement(Foundation.View, {
				tag = "size-full col shrink",
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

return App
