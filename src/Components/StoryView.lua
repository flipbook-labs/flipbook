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
	local controls, setControls = hooks.useState(story.controls)

	local setControl = hooks.useCallback(function(control: string, newValue: any)
		local newControls = Llama.Dictionary.join(controls, {
			[control] = newValue,
		})
		setControls(newControls)
	end, { controls })

	local viewCode = hooks.useCallback(function()
		Selection:Set({ props.story })
		plugin:OpenScript(props.story)
	end, { plugin, props.story })

	local isMountedInViewport, setIsMountedInViewport = hooks.useState(false)

	local onPreviewInViewport = hooks.useCallback(function()
		setIsMountedInViewport(not isMountedInViewport)
	end, { isMountedInViewport, setIsMountedInViewport })

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

			StoryMeta = e(StoryMeta, {
				layoutOrder = 1,
				story = story,
				storyModule = props.story,
			}),

			StoryPreview = e(StoryPreview, {
				layoutOrder = 2,
				zoom = zoom.value,
				story = story,
				storyModule = props.story,
				isMountedInViewport = isMountedInViewport,
			}),

			StoryControls = story.controls and e(StoryControls, {
				layoutOrder = 3,
				controls = controls,
				setControl = setControl,
			}),
		}),
	})
end

return hook(StoryView)
