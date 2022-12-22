local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local types = require(script.Parent.Parent.types)
local usePrevious = require(flipbook.Hooks.usePrevious)
local useTheme = require(flipbook.Hooks.useTheme)
local mountStory = require(flipbook.Story.mountStory)
local unmountStory = require(flipbook.Story.unmountStory)

local e = Roact.createElement

local defaultProps = {
	isMountedInViewport = false,
	zoom = 0,
}

type Props = typeof(defaultProps) & {
	layoutOrder: number,
	prevStory: types.Story,
	story: types.Story,
	controls: { [string]: any },
	storyModule: ModuleScript,
}

local function StoryPreview(props: Props, hooks: any)
	local theme = useTheme(hooks)
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
			tree.value = mountStory(props.story, props.controls, storyParent:getValue())
		end
	end, { props.story, unmount, storyParent })

	if props.isMountedInViewport then
		return e(Roact.Portal, {
			target = CoreGui,
		}, {
			Story = e("ScreenGui", {
				[Roact.Ref] = storyParent,
			}),
		})
	else
		return e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = props.layoutOrder,
			Size = UDim2.fromScale(1, 0),
			[Roact.Ref] = storyParent,
		}, {
			Scale = e("UIScale", {
				Scale = 1 + props.zoom,
			}),
		})
	end
end

return hook(StoryPreview, {
	defaultProps = defaultProps,
})
