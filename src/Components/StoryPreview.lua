local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local types = require(script.Parent.Parent.types)
local mountStory = require(flipbook.Story.mountStory)

local e = Roact.createElement

local defaultProps = {
	isMountedInViewport = false,
	zoom = 0,
}

type Props = typeof(defaultProps) & {
	layoutOrder: number,
	story: types.Story,
	controls: { [string]: any },
	storyModule: ModuleScript,
}

local function StoryPreview(props: Props, hooks: any)
	local storyParent = Roact.createRef()

	hooks.useEffect(function()
		local cleanup
		if props.story then
			cleanup = mountStory(props.story, props.controls, storyParent:getValue())
		end

		return function()
			if cleanup then
				cleanup()
			end
		end
	end, { props.story, storyParent })

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
