local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local types = require(flipbook.types)
local usePrevious = require(flipbook.Hooks.usePrevious)
local mountStory = require(flipbook.Story.mountStory)
local unmountStory = require(flipbook.Story.unmountStory)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	prevStory: types.Story,
	story: types.Story,
	storyModule: ModuleScript,
}

local function StoryPreview(props: Props, hooks: any)
	local tree = hooks.useValue(nil)
	local storyParent = Roact.createRef()
	local prevStory = usePrevious(hooks, props.story)

	local unmount = hooks.useCallback(function()
		if tree.value and prevStory then
			unmountStory(prevStory, tree.value)
			tree.value = nil
		end
	end, { prevStory })

	hooks.useEffect(function()
		unmount()

		if props.story then
			tree.value = mountStory(props.story, storyParent:getValue())
		end
	end, { props.story, unmount, storyParent })

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		[Roact.Ref] = storyParent,
	}, {
		UIPadding = e("UIPadding", {
			PaddingBottom = styles.PADDING,
			PaddingLeft = styles.PADDING,
			PaddingRight = styles.PADDING,
			PaddingTop = styles.PADDING,
		}),
	})
end

return hook(StoryPreview)
