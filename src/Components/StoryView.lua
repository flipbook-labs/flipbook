local flipbook = script:FindFirstAncestor("flipbook")

local Selection = game:GetService("Selection")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local types = require(script.Parent.Parent.types)
local useStory = require(flipbook.Hooks.useStory)
local useTheme = require(flipbook.Hooks.useTheme)
local useZoom = require(flipbook.Hooks.useZoom)
local StoryViewNavbar = require(flipbook.Components.StoryViewNavbar)
local StoryControls = require(flipbook.Components.StoryControls)
local StoryMeta = require(flipbook.Components.StoryMeta)
local StoryPreview = require(flipbook.Components.StoryPreview)
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

	local showControls = controls and not Llama.isEmpty(controls)

	local setControl = hooks.useCallback(function(control: string, newValue: any)
		setControls(function(prevControls)
			return Llama.Dictionary.join(prevControls, {
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

	hooks.useEffect(function()
		setControls(if story then story.controls else nil)
	end, { story })

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = theme.paddingLarge,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		StoryViewNavbar = story and e(StoryViewNavbar, {
			layoutOrder = 1,
			onPreviewInViewport = onPreviewInViewport,
			onZoomIn = zoom.zoomIn,
			onZoomOut = zoom.zoomOut,
			onViewCode = viewCode,
		}),

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
			Size = UDim2.fromScale(1, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = theme.padding,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Padding = e("UIPadding", {
				PaddingLeft = theme.padding,
				PaddingRight = theme.padding,
			}),

			StoryMeta = e(StoryMeta, {
				layoutOrder = 1,
				story = story,
				storyModule = props.story,
			}),

			StoryPreview = e(StoryPreview, {
				layoutOrder = 2,
				zoom = zoom.value,
				story = story,
				controls = controls,
				storyModule = props.story,
				isMountedInViewport = isMountedInViewport,
			}),

			Divider = showControls and e("Frame", {
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = theme.divider,
				BorderSizePixel = 0,
			}),

			StoryControls = showControls and e(StoryControls, {
				layoutOrder = 4,
				controls = controls,
				setControl = setControl,
			}),
		}),
	})
end

return hook(StoryView)
