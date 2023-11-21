local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local types = require(script.Parent.Parent.types)
local NoStorySelected = require(flipbook.Components.NoStorySelected)
local StoryView = require(flipbook.Components.StoryView)
local useTheme = require(flipbook.Hooks.useTheme)

local e = React.createElement

type Props = {
	story: ModuleScript,
	loader: any,
	storybook: types.Storybook,
	layoutOrder: number?,
}

local function Canvas(props: Props)
	local theme = useTheme()

	return e("Frame", {
		BackgroundColor3 = theme.canvas,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, 1),
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 1, 1, 0),
		}),

		Content = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = theme.paddingLarge,
				SortOrder = Enum.SortOrder.LayoutOrder,
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

return Canvas
