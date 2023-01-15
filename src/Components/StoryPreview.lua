local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local types = require(script.Parent.Parent.types)
local mountStory = require(flipbook.Story.mountStory)

local e = React.createElement

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

local function StoryPreview(props: Props)
	props = Sift.Dictionary.merge(defaultProps, props)

	local storyParent = React.useRef()

	React.useEffect(function()
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
		return e(React.Portal, {
			target = CoreGui,
		}, {
			Story = e("ScreenGui", {
				ref = storyParent,
			}),
		})
	else
		return e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = props.layoutOrder,
			Size = UDim2.fromScale(1, 0),
			ref = storyParent,
		}, {
			Scale = e("UIScale", {
				Scale = 1 + props.zoom,
			}),
		})
	end
end

return StoryPreview
