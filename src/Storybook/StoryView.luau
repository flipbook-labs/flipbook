local Selection = game:GetService("Selection")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")
local Storyteller = require("@pkg/Storyteller")

local PluginStore = require("@root/Plugin/PluginStore")
local ResizablePanel = require("@root/Panels/ResizablePanel")
local StoryControls = require("@root/Storybook/StoryControls")
local StoryError = require("@root/Storybook/StoryError")
local StoryMeta = require("@root/Storybook/StoryMeta")
local StoryPreview = require("@root/Storybook/StoryPreview")
local StoryViewNavbar = require("@root/Storybook/StoryViewNavbar")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local constants = require("@root/constants")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useZoom = require("@root/Common/useZoom")

local useSignalState = SignalsReact.useSignalState

local e = React.createElement

type LoadedStorybook = Storyteller.LoadedStorybook

type Props = {
	story: ModuleScript,
	storybook: LoadedStorybook,
}

local function StoryView(props: Props)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local story, storyErr = Storyteller.useStory(props.story, props.storybook)
	local zoom = useZoom(props.story)
	local pluginStore = useSignalState(PluginStore.get)
	local plugin: Plugin? = useSignalState(pluginStore.getPlugin)
	local changedControls, setChangedControls = React.useState({})
	local storyParentRef = React.useRef(nil :: GuiObject?)

	React.useEffect(function()
		setChangedControls({})
	end, { story })

	local controlsWithUserOverrides = React.useMemo(function()
		local controls = {}
		if story and story.controls then
			for key, value in story.controls do
				local override = changedControls[key]

				if override ~= nil and typeof(value) ~= "table" then
					controls[key] = override
				else
					controls[key] = value
				end
			end
		end
		return controls
	end, { story, changedControls } :: { unknown })

	local showControls = controlsWithUserOverrides and not Sift.isEmpty(controlsWithUserOverrides)

	local setControl = React.useCallback(function(control: string, newValue: any)
		setChangedControls(function(prev)
			return Sift.Dictionary.merge(prev, {
				[control] = newValue,
			})
		end)
	end, {})

	local viewCode = React.useCallback(function()
		Selection:Set({ props.story })
		if plugin then
			plugin:OpenScript(props.story)
		end
	end, { plugin, props.story } :: { unknown })

	local exploreStoryParent = React.useCallback(function()
		local current = storyParentRef.current
		if current then
			local firstGuiObject = current:FindFirstChildWhichIsA("GuiObject")
			Selection:Set({ if firstGuiObject then firstGuiObject else current })
		end

		-- TODO: If PluginGuiService is not enabled, display a toast letting the user know
	end, { storyParentRef })

	local isMountedInViewport, setIsMountedInViewport = React.useState(false)

	local onPreviewInViewport = React.useCallback(function()
		setIsMountedInViewport(not isMountedInViewport)
	end, { isMountedInViewport, setIsMountedInViewport } :: { unknown })

	return e(Foundation.View, {
		tag = "size-full",
	}, {
		Error = storyErr and e(StoryError, {
			err = storyErr,
		}),

		Content = story and e(Foundation.View, {
			tag = "size-full col flex-between",
		}, {
			TopbarWrapper = e(Foundation.View, {
				tag = "size-full-0 auto-y padding-x-medium col gap-large",
				LayoutOrder = nextLayoutOrder(),
			}, {
				StoryViewNavbar = e(StoryViewNavbar, {
					onPreviewInViewport = onPreviewInViewport,
					onZoomIn = zoom.zoomIn,
					onZoomOut = zoom.zoomOut,
					onViewCode = viewCode,
					onExplorer = exploreStoryParent,
				}),

				StoryMeta = e(StoryMeta, {
					layoutOrder = nextLayoutOrder(),
					story = story,
					storyModule = props.story,
				}),

				Divider = e(Foundation.Divider, {
					LayoutOrder = nextLayoutOrder(),
				}),
			}),

			StoryWrapper = e(Foundation.View, {
				-- TODO: Apply larger padding on the top than the rest
				tag = "size-full shrink padding-medium",
				LayoutOrder = nextLayoutOrder(),
			}, {
				StoryPreview = e(StoryPreview, {
					zoom = zoom.value,
					story = story,
					controls = Sift.Dictionary.merge(controlsWithUserOverrides, changedControls),
					storyModule = props.story,
					isMountedInViewport = isMountedInViewport,
					ref = storyParentRef,
				}),
			}),

			StoryControlsWrapper = showControls and e(ResizablePanel, {
				layoutOrder = nextLayoutOrder(),
				initialSize = UDim2.new(1, 0, 0, userSettings.controlsHeight),
				dragHandles = {
					-- Luau FIXME: Type '{string}' could not be converted into '{"Bottom" | "Left" | "Right" | "Top"}'
					"Top" :: any,
				},
				minSize = Vector2.new(0, constants.CONTROLS_MIN_HEIGHT),
				maxSize = Vector2.new(math.huge, constants.CONTROLS_MAX_HEIGHT),
			}, {
				ScrollingFrame = e(Foundation.ScrollView, {
					tag = "size-full bg-surface-100",
					scroll = {
						ScrollingDirection = Enum.ScrollingDirection.Y,
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.new(1, 0),
					},
				}, {
					StoryControls = e(StoryControls, {
						controls = controlsWithUserOverrides,
						setControl = setControl,
					}),
				}),
			}),
		}),
	})
end

return StoryView
