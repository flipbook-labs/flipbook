local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local types = require(flipbook.types)
local NoStorySelected = require(flipbook.Components.NoStorySelected)
local StoryView = require(flipbook.Components.StoryView)
local useTailwind = require(flipbook.Hooks.useTailwind)

local e = Roact.createElement

type Props = {
	layoutOrder: number,
	loader: any,
	story: ModuleScript,
	storybook: types.Storybook,
}

local function Canvas(props: Props, hooks: any)
	return e("Frame", {
		BackgroundColor3 = useTailwind("white"),
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.new(1, -267, 1, 0),
	}, {
		Divider = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = useTailwind("gray-300"),
			BorderSizePixel = 0,
			Size = UDim2.new(0, 1, 1, 0),
		}),

		Content = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 50),
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

return hook(Canvas)
