local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

local nextLayoutOrder = require(script.Parent.Parent.Common.nextLayoutOrder)

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
