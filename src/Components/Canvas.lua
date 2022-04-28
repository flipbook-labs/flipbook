local hook = require(script.Parent.Parent.hook)
local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local NoStorySelected = require(script.Parent.NoStorySelected)
local Roact = require(script.Parent.Parent.Packages.Roact)
local StoryView = require(script.Parent.StoryView)
local styles = require(script.Parent.Parent.styles)
local types = require(script.Parent.Parent.types)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	story: ModuleScript,
	loader: ModuleLoader.Class,
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
				loader = props.loader,
				story = props.story,
				storybook = props.storybook,
			}),

			NoStorySelected = not props.story and e(NoStorySelected),
		}),
	})
end

return hook(Canvas)
