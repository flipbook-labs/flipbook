local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local usePrevious = require(script.Parent.Parent.Hooks.usePrevious)
local mountStory = require(script.Parent.Parent.Stories.mountStory)
local unmountStory = require(script.Parent.Parent.Stories.unmountStory)

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
