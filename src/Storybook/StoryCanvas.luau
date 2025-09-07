local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local StoryView = require("@root/Storybook/StoryView")

local e = React.createElement

type LoadedStorybook = Storyteller.LoadedStorybook

type Props = {
	story: ModuleScript,
	storybook: LoadedStorybook,
	layoutOrder: number?,
}

local function Canvas(props: Props)
	return e(Foundation.View, {
		tag = "size-full col gap-medium bg-surface-200",
		LayoutOrder = props.layoutOrder,
	}, {
		StoryView = props.story and e(StoryView, {
			story = props.story,
			storybook = props.storybook,
		}),
	})
end

return Canvas
