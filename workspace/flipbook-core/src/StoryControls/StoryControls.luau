local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Constants = require("@root/constants")
local ReactSignals = require("@rbxpkg/SignalsReact")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local StoryControlRow = require("@root/StoryControls/StoryControlRow")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local useSortedControls = require("@root/StoryControls/useSortedControls")

local Divider = Foundation.Divider
local ScrollView = Foundation.ScrollView
local Text = Foundation.Text
local View = Foundation.View
local useTokens = Foundation.Hooks.useTokens
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useMemo = React.useMemo

local useSignalState = ReactSignals.useSignalState

type StoryControlsProps = {
	controlsSchema: Storyteller.StoryControlsSchema,
	controls: Storyteller.StoryControls,
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

	local sortedControls = useSortedControls(props.controlsSchema)
	local controlElements: { [string]: React.ReactNode } = {}

	local sortedControlNames = useMemo(function()
		local names: { string } = {}
		for name in props.controlsSchema do
			table.insert(names, name)
		end
		table.sort(names)
		return names
	end, { props.controlsSchema })

	print(sortedControlNames)

	for index, name in sortedControlNames do
		local control: (Storyteller.StoryControl | Storyteller.StoryControlValue)? = props.controlsSchema[name]

		-- TODO: Properly handle when we get a StoryControlValue back. This is
		-- just to clear the type error for now
		if typeof(control) ~= "table" then
			continue
		end

		controlElements[name] = e(View, {
			LayoutOrder = index,
			tag = "auto-y col size-full-0",
		}, {
			Row = e(StoryControlRow, {
				controlName = name,
				control = control,
				setControl = props.setControl,
				controls = props.controls,
				LayoutOrder = 1,
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
