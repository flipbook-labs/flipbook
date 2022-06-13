local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Navbar = require(script.Navbar)
local Roact = require(flipbook.Packages.Roact)
local StoryMeta = require(script.StoryMeta)
local StoryPreview = require(script.StoryPreview)
local types = require(flipbook.types)
local useStory = require(flipbook.Hooks.useStory)

local e = Roact.createElement

type Props = {
	loader: any,
	story: ModuleScript,
	storybook: types.Storybook,
}

local function StoryView(props: Props, hooks: any)
	local story = useStory(hooks, props.story, props.storybook, props.loader)

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 50),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Navbar = story and e(Navbar),

		Content = story and e("ScrollingFrame", {
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			UIListLayout = e("UIListLayout", {
				Padding = UDim.new(0, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			StoryMeta = story and e(StoryMeta, {
				layoutOrder = 1,
				story = story,
				storyModule = props.story,
			}),

			StoryPreview = story and e(StoryPreview, {
				layoutOrder = 2,
				story = story,
				storyModule = props.story,
			}),
		}),
	})
end

return hook(StoryView)
