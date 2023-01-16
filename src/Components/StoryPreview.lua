local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local useTheme = require(flipbook.Hooks.useTheme)
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

	local theme = useTheme()
	local err, setErr = React.useState(nil)
	local storyParent = React.useRef()

	React.useEffect(function()
		setErr(nil)

		if props.story then
			local success, result = xpcall(function()
				return mountStory(props.story, props.controls, storyParent.current)
			end, debug.traceback)

			if success then
				return result
			else
				setErr(result)
				return nil
			end
		end

		return nil
	end, { props.story, props.controls, storyParent })

	if err then
		return e("TextLabel", {
			LayoutOrder = props.layoutOrder,
			BackgroundTransparency = 1,
			Font = theme.font,
			Size = UDim2.fromScale(1, 1),
			Text = err,
			TextColor3 = theme.text,
			TextWrapped = true,
			TextSize = theme.textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			Padding = e("UIPadding", {
				PaddingTop = theme.padding,
				PaddingRight = theme.padding,
				PaddingBottom = theme.padding,
				PaddingLeft = theme.padding,
			}),
		})
	else
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
end

return StoryPreview
