local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local BuildChannel = require("@root/Enums/BuildChannel")
local BuildTarget = require("@root/Enums/BuildTarget")
local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local PanelTypes = require("@root/Panels/types")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local TelemetryConsentDialog = require("@root/Telemetry/TelemetryConsentDialog")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useEffect = React.useEffect
local useSignalState = ReactCharm.useSignalState

local function FlipbookApp()
	local flipbookStore = FlipbookStoreContext.use()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	--[[
		The navigation store sends a PageChanged event when navigateTo or goBack
		runs. Creating the store sends nothing, so building one has no side
		effects. This sends the event for the screen the app opens on, once the
		app mounts with its store.
	]]
	useEffect(function()
		flipbookStore.navigation.reportCurrentScreen()
	end, { flipbookStore })

	return React.createElement(Foundation.View, {
		tag = "size-full row align-y-center flex-between",
	}, {
		SidebarWrapper = React.createElement(ResizablePanel, {
			LayoutOrder = nextLayoutOrder(),
			initialSize = UDim2.new(0, userSettings.sidebarWidth, 1, 0),
			dragHandles = { PanelTypes.DragHandle.Right },
			minSize = Vector2.new(constants.SIDEBAR_MIN_WIDTH, 0),
			maxSize = Vector2.new(constants.SIDEBAR_MAX_WIDTH, math.huge),
		}, {
			Sidebar = React.createElement(Sidebar),
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
				Screen = React.createElement(Screen),
			}),
		}),

		TelemetryConsentDialog = React.createElement(TelemetryConsentDialog),
	})
end

return FlipbookApp
