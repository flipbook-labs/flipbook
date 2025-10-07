local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

local StoryView = require(script.Parent.StoryView)

local e = React.createElement

type LoadedStorybook = Storyteller.LoadedStorybook

type Props = {
	story: ModuleScript,
	storybook: LoadedStorybook,
	layoutOrder: number?,
}

local function Canvas(props: Props)
	return e(Foundation.View, {
		tag = "size-full bg-surface-200",
		LayoutOrder = props.layoutOrder,
	}, {
		StoryView = props.story and e(StoryView, {
			story = props.story,
			storybook = props.storybook,
		}),
	})
end

return Canvas
