local flipbook = script:FindFirstAncestor("flipbook")

local hook = require(flipbook.hook)
local Navbar = require(script.Parent.Navbar)
local Roact = require(flipbook.Packages.Roact)
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

	return e("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		CanvasSize = UDim2.fromScale(1, 0),
		ScrollBarThickness = 4,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 50),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Navbar = story and e(Navbar),
	})
end

return hook(StoryView)
