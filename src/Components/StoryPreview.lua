local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local enums = require(flipbook.enums)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local types = require(flipbook.types)
local getStoryElement = require(flipbook.Modules.getStoryElement)

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

	local unmount = hooks.useCallback(function()
		if tree.value and props.prevStory then
			if props.prevStory.format == enums.Format.Default then
				props.prevStory.roact.unmount(tree.value)
			elseif props.prevStory.format == enums.Format.Hoarcekat then
				local success, result = xpcall(function()
					return tree.value()
				end, debug.traceback)

				if not success then
					warn(result)
				end
			end

			tree.value = nil
		end
	end, { props.prevStory })

	hooks.useEffect(function()
		unmount()

		if props.story then
			if props.story.format == enums.Format.Default then
				--TODO: Reintroduce controls in here.
				local element = getStoryElement(props.story, {})

				xpcall(function()
					tree.value = props.story.roact.mount(element, storyParent:getValue(), props.story.name)
				end, debug.traceback)
			elseif props.story.format == enums.Format.Hoarcekat and typeof(props.story.story) == "function" then
				xpcall(function()
					tree.value = props.story.story(storyParent:getValue())
				end, debug.traceback)
			end
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
