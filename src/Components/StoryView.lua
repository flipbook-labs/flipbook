local flipbook = script:FindFirstAncestor("flipbook")

local Selection = game:GetService("Selection")

local Sift = require(flipbook.Packages.Sift)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local constants = require(flipbook.constants)
local types = require(script.Parent.Parent.types)
local useStory = require(flipbook.Hooks.useStory)
local useTheme = require(flipbook.Hooks.useTheme)
local useZoom = require(flipbook.Hooks.useZoom)
local StoryViewNavbar = require(flipbook.Components.StoryViewNavbar)
local StoryControls = require(flipbook.Components.StoryControls)
local StoryMeta = require(flipbook.Components.StoryMeta)
local StoryPreview = require(flipbook.Components.StoryPreview)
local ResizablePanel = require(flipbook.Components.ResizablePanel)
local ScrollingFrame = require(flipbook.Components.ScrollingFrame)
local PluginContext = require(flipbook.Plugin.PluginContext)

local e = Roact.createElement

type Props = {
	loader: any,
	story: ModuleScript,
	storybook: types.Storybook,
}

local function StoryView(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local story, storyErr = useStory(hooks, props.story, props.storybook, props.loader)
	local zoom = useZoom(hooks, props.story)
	local plugin = hooks.useContext(PluginContext.Context)
	local controls, setControls = hooks.useState(nil)
	local controlsHeight, setControlsHeight = hooks.useState(constants.CONTROLS_INITIAL_HEIGHT)

	local showControls = controls and not Sift.isEmpty(controls)

	local setControl = hooks.useCallback(function(control: string, newValue: any)
		setControls(function(prevControls)
			return Sift.Dictionary.merge(prevControls, {
				[control] = newValue,
			})
		end)
	end, {})

	local viewCode = hooks.useCallback(function()
		Selection:Set({ props.story })
		plugin:OpenScript(props.story)
	end, { plugin, props.story })

	local isMountedInViewport, setIsMountedInViewport = hooks.useState(false)

	local onPreviewInViewport = hooks.useCallback(function()
		setIsMountedInViewport(not isMountedInViewport)
	end, { isMountedInViewport, setIsMountedInViewport })

	local onControlsResized = hooks.useCallback(function(newSize: Vector2)
		setControlsHeight(newSize.Y)
	end, {})

	hooks.useEffect(function()
		setControls(if story then story.controls else nil)
	end, { story })

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Error = storyErr and e("TextLabel", {
			BackgroundTransparency = 1,
			Font = theme.font,
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 1),
			Text = storyErr,
			TextColor3 = theme.text,
			TextWrapped = true,
			TextSize = theme.textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			Padding = e("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.padding,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.padding,
			}),
		}),

		Content = story and e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			ScrollingFrame = e(ScrollingFrame, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, if showControls then controlsHeight else 0),
			}, {
				Layout = e("UIListLayout", {
					Padding = theme.padding,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				Padding = e("UIPadding", {
					PaddingLeft = theme.padding,
					PaddingRight = theme.padding,
				}),

				StoryViewNavbar = e(StoryViewNavbar, {
					layoutOrder = 1,
					onPreviewInViewport = onPreviewInViewport,
					onZoomIn = zoom.zoomIn,
					onZoomOut = zoom.zoomOut,
					onViewCode = viewCode,
				}),

				StoryMeta = e(StoryMeta, {
					layoutOrder = 2,
					story = story,
					storyModule = props.story,
				}),

				Divider = e("Frame", {
					LayoutOrder = 3,
					BackgroundColor3 = theme.divider,
					Size = UDim2.new(1, 0, 0, 1),
					BorderSizePixel = 0,
				}),

				StoryPreview = e(StoryPreview, {
					layoutOrder = 4,
					zoom = zoom.value,
					story = story,
					controls = controls,
					storyModule = props.story,
					isMountedInViewport = isMountedInViewport,
				}),
			}),

			Divider = e("Frame", {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = theme.divider,
				BorderSizePixel = 0,
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

return hook(StoryView)
