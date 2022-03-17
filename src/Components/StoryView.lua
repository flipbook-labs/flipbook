local hook = require(script.Parent.Parent.hook)
local Llama = require(script.Parent.Parent.Packages.Llama)
local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryMeta = require(script.Parent.StoryMeta)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useStory = require(script.Parent.Parent.Hooks.useStory)

local Dictionary = Llama.Dictionary
local e = Roact.createElement

type Props = {
	story: ModuleScript,
	loader: ModuleLoader.Class,
	storybook: types.Storybook,
}

local function StoryView(props: Props, hooks: any)
	local story = useStory(hooks, props.story, props.storybook, props.loader)

	return e("ScrollingFrame", Dictionary.copy(styles.ScrollingFrame), {
		UIPadding = e("UIPadding", {
			PaddingBottom = styles.PADDING,
			PaddingLeft = styles.PADDING,
			PaddingRight = styles.PADDING,
			PaddingTop = styles.PADDING,
		}),

		UIListLayout = e("UIListLayout", {
			Padding = styles.XL_PADDING,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		StoryMeta = story and e(StoryMeta, {
			layoutOrder = 1,
			story = story,
			storyModule = props.story,
		}),
	})
end

return hook(StoryView)
