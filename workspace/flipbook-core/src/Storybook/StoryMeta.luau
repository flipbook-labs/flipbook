local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local MAX_SUMMARY_SIZE = 600

local e = React.createElement

type LoadedStory = Storyteller.LoadedStory<unknown>

export type Props = {
	story: LoadedStory,
	layoutOrder: number?,
}

local function StoryMeta(props: Props)
	return e(Foundation.View, {
		tag = "size-full-0 auto-y col gap-medium",
		LayoutOrder = props.layoutOrder,
	}, {
		Title = e(Foundation.Text, {
			tag = "auto-xy text-heading-large",
			Text = props.story.name,
			LayoutOrder = nextLayoutOrder(),
		}),

		Summary = props.story.summary and e(Foundation.Text, {
			tag = "auto-xy text-body-medium text-wrap",
			LayoutOrder = nextLayoutOrder(),
			Text = props.story.summary,
			sizeConstraint = {
				MaxSize = Vector2.new(MAX_SUMMARY_SIZE, math.huge),
			},
		}),
	})
end

return StoryMeta
