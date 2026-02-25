local Constants = require("@root/constants")
local Foundation = require("@rbxpkg/Foundation")
local LuauPolyfill = require("@pkg/LuauPolyfill")
local React = require("@pkg/React")
local ReactSignals = require("@pkg/ReactCharm")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local useSortedControls = require("@root/Storybook/useSortedControls")

local Checkbox = Foundation.Checkbox
local Divider = Foundation.Divider
local Dropdown = Foundation.Dropdown
local InputSize = Foundation.Enums.InputSize
local NumberInput = Foundation.NumberInput
local ScrollView = Foundation.ScrollView
local Text = Foundation.Text
local TextInput = Foundation.TextInput
local View = Foundation.View
local useTokens = Foundation.Hooks.useTokens
local withCommonProps = Foundation.Utility.withCommonProps

local Array = LuauPolyfill.Array

local e = React.createElement
local useState = React.useState

local useSignalState = ReactSignals.useSignalState

type StoryControlsProps = {
	controls: { [string]: any },
	modifiedControls: { [string]: any },
	setControl: (key: string, value: any) -> (),
} & Foundation.CommonProps

-- NOTE(Paul): In the future, we'll want to store more than just
-- controls here, we'll also want to have tabs for stuff like
-- accessibility as well. I was planning to use the <Foundation.Tabs />
-- component to show-off the Accessibility tab for future purposes,
-- but turns out it doesn't work when in a `col` with a `shrink size-full`
-- as it's sibling.
local function StoryControls(props: StoryControlsProps)
	local tokens = useTokens()

	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local sortedControls = useSortedControls(props.controls)
	local pendingControl, setPendingControl = useState(nil :: string?)
	local controlElements: { [string]: React.ReactNode } = {}

	for index, control in sortedControls do
		local function setControl(newValue: any)
			local newValueAsNumber = tonumber(newValue)

			if newValueAsNumber ~= nil then
				newValue = newValueAsNumber
			end

			props.setControl(control.key, newValue)
		end

		local controlType = typeof(control.value)
		local controlInput: React.ReactNode = nil

		if controlType == "boolean" then
			controlInput = e(Checkbox, {
				isChecked = control.value,
				label = "",
				onActivated = setControl,
				size = InputSize.Small,
			})
		elseif controlType == "number" then
			controlInput = e(NumberInput, {
				label = "",
				onChanged = setControl,
				size = InputSize.Small,
				step = 1,
				value = control.value,
				width = UDim.new(1, 0),
			})
		elseif controlType == "string" then
			controlInput = e(TextInput, {
				label = "",
				onChanged = function(newText)
					setPendingControl(newText)
				end,
				onFocusLost = function()
					setControl(pendingControl)
				end,
				onReturnPressed = function()
					setControl(pendingControl)
				end,
				text = control.value,
				size = InputSize.Small,
				width = UDim.new(1, 0),
			})
		elseif controlType == "table" and Array.isArray(control.value) then
			local changedValue = props.modifiedControls[control.key]
			local controlItems = Array.map(control.value, function(value): Foundation.DropdownItem
				return {
					id = value,
					text = tostring(value),
				}
			end)

			controlInput = e(Dropdown.Root, {
				items = controlItems,
				label = "",
				onItemChanged = setControl,
				size = InputSize.Small,
				value = if changedValue ~= nil then changedValue else control.value[1],
				width = UDim.new(1, 0),
			})
		end

		controlElements[control.key] = e(View, {
			LayoutOrder = index,
			tag = "auto-y col size-full-0",
		}, {
			Content = e(View, {
				LayoutOrder = 1,
				tag = "align-y-center auto-y gap-medium padding-medium row size-full-0",
			}, {
				Title = e(Text, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.2, 0),
					Text = control.key,
					tag = "auto-y text-align-x-left text-label-medium",
				}),

				Option = e(View, {
					LayoutOrder = 2,
					tag = "align-x-left auto-y fill row",
				}, {
					-- Keying by the identity of sortedControls fixes a bug where
					-- the options visually do not update when two stories have the
					-- exact same controls.
					[`Option_{sortedControls}`] = controlInput,
				}),
			}),

			Divider = index < #sortedControls and e(Divider, {
				LayoutOrder = 2,
			}),
		})
	end

	return e(
		ResizablePanel,
		withCommonProps(props, {
			dragHandles = { "Top" :: "Top" },
			initialSize = UDim2.new(1, 0, 0, userSettings.controlsHeight),
			maxSize = Vector2.new(0, Constants.CONTROLS_MAX_HEIGHT),
			minSize = Vector2.new(0, Constants.CONTROLS_MIN_HEIGHT),
		}),
		{
			Content = e(View, {
				tag = "bg-surface-100 col size-full",
			}, {
				-- NOTE(Paul): Adding a temporary pseudo-tab element for the time
				-- being so that we have separation between the controls panel
				-- and the story view.
				Tabs = e(View, {
					LayoutOrder = 1,
					tag = "auto-y col size-full-0",
				}, {
					Tab = e(View, {
						LayoutOrder = 1,
						onActivated = function() end,
						tag = "col size-2000-1100",
					}, {
						Content = e(View, {
							tag = "align-x-center align-y-center row size-full",
						}, {
							Text = e(Text, {
								Text = "Controls",
								tag = "anchor-center-center auto-xy content-emphasis position-center-center text-label-medium",
							}),
						}),

						Border = e(View, {
							Size = UDim2.new(1, 0, 0, tokens.Stroke.Thick),
							backgroundStyle = tokens.Color.System.Contrast,
							tag = "anchor-bottom-center position-bottom-center",
						}),
					}),

					Divider = e(Divider, {
						LayoutOrder = 2,
					}),
				}),

				ScrollContent = e(ScrollView, {
					LayoutOrder = 2,
					scroll = {
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.fromScale(0, 0),
						ScrollingDirection = Enum.ScrollingDirection.Y,
					},
					tag = "col shrink size-full",
				}, {
					Header = e(View, {
						LayoutOrder = 0,
						tag = "auto-y col size-full-0",
					}, {
						Content = e(View, {
							LayoutOrder = 1,
							tag = "auto-y align-y-center gap-medium padding-medium row size-full-0",
						}, {
							Name = e(Text, {
								LayoutOrder = 1,
								Size = UDim2.fromScale(0.2, 0),
								Text = "Name",
								tag = "auto-y content-muted text-align-x-left text-title-medium",
							}),

							Control = e(Text, {
								LayoutOrder = 2,
								Text = "Control",
								tag = "auto-y content-muted fill text-align-x-left text-title-medium",
							}),
						}),

						Divider = e(Divider, {
							LayoutOrder = 2,
						}),
					}),

					Controls = e(React.Fragment, nil, controlElements),
				}),
			}),
		}
	)
end

return React.memo(StoryControls)
