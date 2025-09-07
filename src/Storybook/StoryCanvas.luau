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
		tag = "size-full bg-surface-200",
		LayoutOrder = props.layoutOrder,
	}, {
		Divider = e(Foundation.Divider, {
			tag = "size-full-50 bg-surface-200 anchor-right-center",
		}),

		Content = e(Foundation.View, {
			tag = "size-full col gap-medium",
		}, {
			StoryView = props.story and e(StoryView, {
				story = props.story,
				storybook = props.storybook,
			}),
		}),
	})
end

return Canvas
