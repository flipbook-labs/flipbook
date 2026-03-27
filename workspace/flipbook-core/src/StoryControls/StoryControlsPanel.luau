local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local Constants = require("@root/constants")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local StoryControls = require("@root/Storybook/StoryControls")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local e = React.createElement

local withCommonProps = Foundation.Utility.withCommonProps
local useSignalState = ReactCharm.useSignalState

export type StoryControlsPanelProps = StoryControls.StoryControlsProps & Foundation.CommonProps

local function StoryControlsPanel(props: StoryControlsPanelProps)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	return e(
		ResizablePanel,
		withCommonProps(props, {
			dragHandles = { "Top" :: "Top" },
			initialSize = UDim2.new(1, 0, 0, userSettings.controlsHeight),
			maxSize = Vector2.new(0, Constants.CONTROLS_MAX_HEIGHT),
			minSize = Vector2.new(0, Constants.CONTROLS_MIN_HEIGHT),
		}),
		{
			StoryControls = e(StoryControls, {
				controlsSchema = props.controlsSchema,
				controls = props.controls,
				setControl = props.setControl,
			}),
		}
	)
end

return React.memo(StoryControlsPanel)
