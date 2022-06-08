local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local types = require(flipbook.types)
local useStory = require(flipbook.Hooks.useStory)
local StoryMeta = require(script.Parent.StoryMeta)
local StoryPreview = require(script.Parent.StoryPreview)
local StoryTopbar = require(script.Parent.StoryTopbar)

local Dictionary = Llama.Dictionary
local e = Roact.createElement

type Props = {
	story: ModuleScript,
	loader: any,
	storybook: types.Storybook,
}

local function usePrevious(hooks: any, value: any)
	local previous = hooks.useValue(nil)

	hooks.useEffect(function()
		previous.value = value
	end, { value })

	return previous.value
end

local function StoryView(props: Props, hooks: any)
	local story = useStory(hooks, props.story, props.storybook, props.loader)
	local prevStory = usePrevious(hooks, story)

	return e("ScrollingFrame", Dictionary.copy(styles.ScrollingFrame), {
		UIListLayout = e("UIListLayout", {
			Padding = styles.XL_PADDING,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		StoryTopbar = story and e(StoryTopbar, {
			layoutOrder = 1,
		}),

		StoryMeta = story and e(StoryMeta, {
			layoutOrder = 2,
			story = story,
			storyModule = props.story,
		}),

		StoryPreview = story and e(StoryPreview, {
			layoutOrder = 3,
			prevStory = prevStory,
			story = story,
			storyModule = props.story,
		}),
	})
end

return hook(StoryView)
