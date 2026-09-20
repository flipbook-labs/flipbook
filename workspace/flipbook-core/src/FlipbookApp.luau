local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local BuildChannel = require("@root/Enums/BuildChannel")
local BuildTarget = require("@root/Enums/BuildTarget")
local EmbeddingTypes = require("@root/Embedding/types")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local Screen = require("@root/Navigation/Screen")
local Sidebar = require("@root/Panels/Sidebar")
local TelemetryOptOutDialog = require("@root/Telemetry/TelemetryOptOutDialog")
local Topbar = require("@root/Panels/Topbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useSignalState = ReactCharm.useSignalState

type LaunchData = EmbeddingTypes.LaunchData

export type Props = {
	launchData: LaunchData?,
}

local function FlipbookApp(props: Props)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	return React.createElement(Foundation.View, {
		tag = "size-full row align-y-center flex-between",
	}, {
		SidebarWrapper = React.createElement(ResizablePanel, {
			LayoutOrder = nextLayoutOrder(),
			initialSize = UDim2.new(0, userSettings.sidebarWidth, 1, 0),
			dragHandles = { "Right" :: "Right" },
			minSize = Vector2.new(constants.SIDEBAR_MIN_WIDTH, 0),
			maxSize = Vector2.new(constants.SIDEBAR_MAX_WIDTH, math.huge),
		}, {
			Sidebar = React.createElement(Sidebar, {
				launchData = props.launchData,
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
				Screen = React.createElement(Screen),
			}),
		}),

		TelemetryOptOutDialog = React.createElement(TelemetryOptOutDialog),
	})
end

return FlipbookApp
