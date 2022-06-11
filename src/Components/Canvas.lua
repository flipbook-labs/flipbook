local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Roact = require(flipbook.Packages.Roact)
local styles = require(flipbook.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(flipbook.Hooks.useThemeNew)
local NoStorySelected = require(script.Parent.NoStorySelected)
local StoryView = require(script.Parent.StoryView)

local e = Roact.createElement

type Props = {
	story: ModuleScript,
	storybook: types.Storybook,
}

local function Canvas(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Size = UDim2.new(1, -260, 1, -20),
	}, {
		Dropshadow = e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6150493168",
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.95,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(1, 40, 1, 40),
			SliceCenter = Rect.new(100, 100, 100, 100),
			SliceScale = 0.3,
		}),

		Container = e("Frame", {
			BackgroundColor3 = theme.canvas,
			Size = UDim2.fromScale(1, 1),
		}, {
			UICorner = e("UICorner", {
				CornerRadius = styles.SMALL_PADDING,
			}),

			StoryView = props.story and e(StoryView, {
				story = props.story,
				storybook = props.storybook,
			}),

			NoStorySelected = not props.story and e(NoStorySelected),
		}),
	})
end

return hook(Canvas)
