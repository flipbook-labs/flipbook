local flipbook = script:FindFirstAncestor("flipbook")

local Selection = game:GetService("Selection")

local PluginContext = require(flipbook.Plugin.PluginContext)
local React = require(flipbook.Packages.React)
local ResizablePanel = require(flipbook.Panels.ResizablePanel)
local ScrollingFrame = require(flipbook.Common.ScrollingFrame)
local Sift = require(flipbook.Packages.Sift)
local StoryControls = require(flipbook.Storybook.StoryControls)
local StoryError = require(flipbook.Storybook.StoryError)
local StoryMeta = require(flipbook.Storybook.StoryMeta)
local StoryPreview = require(flipbook.Storybook.StoryPreview)
local StoryViewNavbar = require(flipbook.Storybook.StoryViewNavbar)
local constants = require(flipbook.constants)
local types = require(flipbook.Storybook.types)
local useStory = require(flipbook.Storybook.useStory)
local useTheme = require(flipbook.Common.useTheme)
local useZoom = require(flipbook.Common.useZoom)

local e = React.createElement

type Props = {
	loader: any,
	story: ModuleScript,
	storybook: types.Storybook,
}

local function StoryView(props: Props)
	local theme = useTheme()
	local story, storyErr = useStory(props.story, props.storybook, props.loader)
	local zoom = useZoom(props.story)
	local plugin = React.useContext(PluginContext.Context)
	local extraControls, setExtraControls = React.useState({})
	local controlsHeight, setControlsHeight = React.useState(constants.CONTROLS_INITIAL_HEIGHT)
	local topbarHeight, setTopbarHeight = React.useState(0)
	local storyParentRef = React.useRef(nil :: GuiObject?)
	local controls

	if story and story.controls then
		controls = {}

		for key, value in story.controls do
			local override = extraControls[key]

			if override ~= nil and typeof(value) ~= "table" then
				controls[key] = override
			else
				controls[key] = value
			end
		end
	end

	local showControls = controls and not Sift.isEmpty(controls)
	local setControl = React.useCallback(function(control: string, newValue: any)
		setExtraControls(function(prev)
			return Sift.Dictionary.merge(prev, {
				[control] = newValue,
			})
		end)
	end, {})

	local viewCode = React.useCallback(function()
		Selection:Set({ props.story })
		plugin:OpenScript(props.story)
	end, { plugin, props.story })

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
	end, { isMountedInViewport, setIsMountedInViewport })

	local onControlsResized = React.useCallback(function(newSize: Vector2)
		setControlsHeight(newSize.Y)
	end, {})

	local onTopbarSizeChanged = React.useCallback(function(rbx: Frame)
		setTopbarHeight(rbx.AbsoluteSize.Y)
	end, {})

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Error = storyErr and e(StoryError, {
			err = storyErr,
		}),

		Content = story and e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TopbarWrapper = e("Frame", {
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				[React.Change.AbsoluteSize] = onTopbarSizeChanged,
			}, {
				Layout = e("UIListLayout", {
					Padding = theme.paddingLarge,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				StoryViewNavbar = e(StoryViewNavbar, {
					onPreviewInViewport = onPreviewInViewport,
					onZoomIn = zoom.zoomIn,
					onZoomOut = zoom.zoomOut,
					onViewCode = viewCode,
					onExplorer = exploreStoryParent,
				}),

				Padding = e("UIPadding", {
					PaddingRight = theme.padding,
					PaddingLeft = theme.padding,
				}),

				StoryMeta = e(StoryMeta, {
					layoutOrder = 1,
					story = story,
					storyModule = props.story,
				}),

				Divider = e("Frame", {
					LayoutOrder = 2,
					BackgroundColor3 = theme.divider,
					Size = UDim2.new(1, 0, 0, 1),
					BorderSizePixel = 0,
				}),
			}),

			StoryWrapper = e("Frame", {
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1)
					- UDim2.fromOffset(0, if showControls then controlsHeight else 0)
					- UDim2.fromOffset(0, topbarHeight),
			}, {
				Padding = e("UIPadding", {
					PaddingTop = theme.paddingLarge,
					PaddingRight = theme.padding,
					PaddingBottom = theme.padding,
					PaddingLeft = theme.padding,
				}),

				StoryPreview = e(StoryPreview, {
					zoom = zoom.value,
					story = story,
					controls = Sift.Dictionary.merge(controls, extraControls),
					storyModule = props.story,
					isMountedInViewport = isMountedInViewport,
					ref = storyParentRef,
				}),
			}),

			StoryControlsWrapper = showControls and e(ResizablePanel, {
				layoutOrder = 3,
				initialSize = UDim2.new(1, 0, 0, constants.CONTROLS_INITIAL_HEIGHT),
				dragHandles = { "Top" },
				minSize = Vector2.new(0, constants.CONTROLS_MIN_HEIGHT),
				maxSize = Vector2.new(math.huge, constants.CONTROLS_MAX_HEIGHT),
				onResize = onControlsResized,
			}, {
				ScrollingFrame = e(ScrollingFrame, {
					LayoutOrder = 2,
					BackgroundTransparency = 0.4,
					BackgroundColor3 = theme.sidebar,
				}, {
					Padding = e("UIPadding", {
						PaddingTop = theme.padding,
						PaddingRight = theme.padding,
						PaddingBottom = theme.padding,
						PaddingLeft = theme.padding,
					}),

					StoryControls = e(StoryControls, {
						controls = controls,
						setControl = setControl,
					}),
				}),
			}),
		}),
	})
end

return StoryView
