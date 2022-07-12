local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local types = require(script.Parent.Parent.types)
local useStory = require(flipbook.Hooks.useStory)
local useTheme = require(flipbook.Hooks.useTheme)
local StoryViewNavbar = require(flipbook.Components.StoryViewNavbar)
local StoryControls = require(flipbook.Components.StoryControls)
local StoryMeta = require(flipbook.Components.StoryMeta)
local StoryPreview = require(flipbook.Components.StoryPreview)

local e = Roact.createElement

type Props = {
	loader: any,
	story: ModuleScript,
	storybook: types.Storybook,
}

local function StoryView(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local story = useStory(hooks, props.story, props.storybook, props.loader)

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

			StoryMeta = story and e(StoryMeta, {
				layoutOrder = 2,
				story = story,
				storyModule = props.story,
			}),

			StoryPreview = story and e(StoryPreview, {
				layoutOrder = 3,
				story = story,
				storyModule = props.story,
				isMountedInViewport = isMountedInViewport,
			}),

			StoryControls = story and e(StoryControls, {
				layoutOrder = 4,
			}),
		}),
	})
end

return hook(StoryView)
