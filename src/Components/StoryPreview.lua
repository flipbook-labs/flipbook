local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local types = require(script.Parent.Parent.types)
local usePrevious = require(flipbook.Hooks.usePrevious)
local mountStory = require(flipbook.Story.mountStory)
local unmountStory = require(flipbook.Story.unmountStory)

local e = React.createElement

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

local function StoryPreview(props: Props)
	props = Sift.Dictionary.merge(defaultProps, props)

	local tree = React.useValue(nil)
	local storyParent = React.createRef()
	local prevStory = usePrevious(props.story)

	local unmount = React.useCallback(function()
		if tree.value and prevStory then
			unmountStory(prevStory, tree.value)
			tree.value = nil
		end
	end, { prevStory })

	React.useEffect(function()
		unmount()

		if props.story then
			tree.value = mountStory(props.story, props.controls, storyParent:getValue())
		end
	end, { props.story, unmount, storyParent })

	if props.isMountedInViewport then
		return e(React.Portal, {
			target = CoreGui,
		}, {
			Story = e("ScreenGui", {
				[React.Ref] = storyParent,
			}),
		})
	else
		return e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = props.layoutOrder,
			Size = UDim2.fromScale(1, 0),
			[React.Ref] = storyParent,
		}, {
			Scale = e("UIScale", {
				Scale = 1 + props.zoom,
			}),
		})
	end
end

return StoryPreview
